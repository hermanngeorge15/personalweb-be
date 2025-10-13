package com.jirihermann.be.contact

import com.jirihermann.be.email.ContactFormEmailData
import com.jirihermann.be.email.EmailService
import com.jirihermann.be.recaptcha.RecaptchaServiceImpl
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.time.Duration
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.concurrent.*

@RestController
@RequestMapping("/api/contact")
@Tag(name = "Contact")
@Validated
class ContactController(
    private val repo: ContactMessageRepo,
    private val emailService: EmailService,
    private val recaptchaService: RecaptchaServiceImpl,
) {
    private val lastHitByIp: ConcurrentHashMap<String, MutableList<Instant>> = ConcurrentHashMap()
    private val window: Duration = Duration.ofMinutes(1)
    private val maxRequests: Int = 5
    private val dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss z")

    @PostMapping
    @Operation(summary = "Submit contact message (public)")
    @ResponseStatus(HttpStatus.ACCEPTED)
    suspend fun submit(
        @RequestBody body: ContactRequest,
        @RequestHeader(value = "X-Forwarded-For", required = false) xff: String?,
        @RequestHeader(value = "X-Real-IP", required = false) xri: String?
    ) {
        // Honeypot check
        if (!body.website.isNullOrBlank()) {
            logger.warn("Honeypot triggered for email: ${body.email}")
            return
        }

        val ip = (xff?.split(",")?.firstOrNull()?.trim()).takeUnless { it.isNullOrBlank() }
            ?: xri
            ?: "unknown"

        // reCAPTCHA verification
        if (body.recaptchaToken.isNullOrBlank()) {
            logger.warn("Missing reCAPTCHA token from IP: $ip")
            throw IllegalArgumentException("CAPTCHA verification required")
        }

        val recaptchaResult = recaptchaService.verifyToken(body.recaptchaToken, ip)
        if (!recaptchaResult.success || !recaptchaService.isScoreAcceptable(recaptchaResult.score)) {
            logger.warn("reCAPTCHA verification failed for IP: $ip, score: ${recaptchaResult.score}")
            throw IllegalArgumentException("CAPTCHA verification failed")
        }

        // Rate limiting
        val now = Instant.now()
        val hits = lastHitByIp.computeIfAbsent(ip) { mutableListOf() }
        hits.removeIf { Duration.between(it, now) > window }
        if (hits.size >= maxRequests) {
            logger.warn("Rate limit exceeded for IP: $ip")
            return
        }
        hits.add(now)

        // Save to database
        repo.save(
            ContactMessageEntity(
                name = body.name,
                email = body.email,
                message = body.message
            )
        )

        // Send email notification to admin
        val timestamp = now.atZone(ZoneId.systemDefault()).format(dateFormatter)
        emailService.sendContactFormNotification(
            ContactFormEmailData(
                name = body.name,
                email = body.email,
                message = body.message,
                timestamp = timestamp
            )
        )
    }

    companion object {
        private val logger = org.slf4j.LoggerFactory.getLogger(ContactController::class.java)
    }
}
