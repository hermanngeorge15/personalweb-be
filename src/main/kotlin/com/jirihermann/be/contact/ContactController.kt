package com.jirihermann.be.contact

import com.jirihermann.be.email.ContactFormEmailData
import com.jirihermann.be.email.EmailService
import com.jirihermann.be.logging.LogRedaction.fingerprint
import com.jirihermann.be.metrics.BusinessMetrics
import com.jirihermann.be.metrics.BusinessMetrics.ContactOutcome
import com.jirihermann.be.recaptcha.RecaptchaServiceImpl
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import kotlinx.coroutines.CancellationException
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
    private val metrics: BusinessMetrics,
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
        // Every request is counted exactly once, under the outcome it ended with.
        try {
            metrics.contactSubmission(process(body, xff, xri))
        } catch (e: ContactRejectedException) {
            metrics.contactSubmission(e.outcome)
            throw e
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            metrics.contactSubmission(ContactOutcome.ERROR)
            throw e
        }
    }

    /**
     * Checks, stores and forwards one submission; returns its outcome, or throws
     * [ContactRejectedException] (an [IllegalArgumentException], as before) when it is rejected.
     * The submitter's e-mail and IP are logged only as fingerprints.
     */
    private suspend fun process(body: ContactRequest, xff: String?, xri: String?): ContactOutcome {
        // Honeypot check
        if (!body.website.isNullOrBlank()) {
            logger.warn("Honeypot triggered for email: {}", fingerprint(body.email))
            return ContactOutcome.HONEYPOT
        }

        val ip = (xff?.split(",")?.firstOrNull()?.trim()).takeUnless { it.isNullOrBlank() }
            ?: xri
        val client = fingerprint(ip)
        logger.info("Contact form submission from client: {}", client)
        // reCAPTCHA verification
        if (body.recaptchaToken.isNullOrBlank()) {
            logger.warn("Missing reCAPTCHA token from client: {}", client)
            throw ContactRejectedException(ContactOutcome.CAPTCHA_MISSING, "CAPTCHA verification required")
        }

        val recaptchaResult = recaptchaService.verifyToken(body.recaptchaToken, ip)
        recaptchaResult.score?.let(metrics::recaptchaScore)

        // Verify success
        if (!recaptchaResult.success) {
            logger.warn("reCAPTCHA verification failed for client: {}, errors: {}", client, recaptchaResult.errorCodes)
            throw ContactRejectedException(ContactOutcome.CAPTCHA_FAILED, "CAPTCHA verification failed")
        }
        
        // Verify action
        if (!recaptchaService.isActionValid(recaptchaResult.action)) {
            logger.warn("reCAPTCHA action mismatch for client: {}, got: {}", client, recaptchaResult.action)
            throw ContactRejectedException(ContactOutcome.ACTION_MISMATCH, "CAPTCHA action mismatch")
        }
        
        // Verify hostname (optional)
        if (!recaptchaService.isHostnameValid(recaptchaResult.hostname)) {
            logger.warn("reCAPTCHA hostname mismatch for client: {}, got: {}", client, recaptchaResult.hostname)
            throw ContactRejectedException(ContactOutcome.HOSTNAME_MISMATCH, "CAPTCHA hostname mismatch")
        }
        
        // Verify score
        if (!recaptchaService.isScoreAcceptable(recaptchaResult.score)) {
            logger.warn("reCAPTCHA score too low for client: {}, score: {}", client, recaptchaResult.score)
            throw ContactRejectedException(ContactOutcome.LOW_SCORE, "CAPTCHA verification failed")
        }

        // Rate limiting
        val now = Instant.now()
//        val hits = lastHitByIp.computeIfAbsent(ip) { mutableListOf() }
//        hits.removeIf { Duration.between(it, now) > window }
//        if (hits.size >= maxRequests) {
//            logger.warn("Rate limit exceeded for IP: $ip")
//            return
//        }
//        hits.add(now)

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
        return ContactOutcome.ACCEPTED
    }

    companion object {
        private val logger = org.slf4j.LoggerFactory.getLogger(ContactController::class.java)
    }
}

/** A rejected contact submission; still an [IllegalArgumentException], as before, carrying its [outcome]. */
class ContactRejectedException(val outcome: ContactOutcome, message: String) : IllegalArgumentException(message)
