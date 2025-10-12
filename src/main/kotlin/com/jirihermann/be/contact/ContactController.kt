package com.jirihermann.be.contact

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.validation.annotation.Validated
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.time.Duration
import java.time.Instant
import java.util.concurrent.ConcurrentHashMap


data class ContactRequest(
  @field:NotBlank @field:Size(max = 200)
  val name: String,
  @field:NotBlank @field:Email @field:Size(max = 320)
  val email: String,
  @field:NotBlank @field:Size(max = 4000)
  val message: String,
  val website: String? = null
)

@RestController
@RequestMapping("/api/contact")
@Tag(name = "Contact")
@Validated
class ContactController(private val repo: ContactMessageRepo) {
  private val lastHitByIp: ConcurrentHashMap<String, MutableList<Instant>> = ConcurrentHashMap()
  private val window: Duration = Duration.ofMinutes(1)
  private val maxRequests: Int = 5

  @PostMapping
  @Operation(summary = "Submit contact message (public)")
  @ResponseStatus(HttpStatus.ACCEPTED)
  suspend fun submit(
    @RequestBody body: ContactRequest,
    @RequestHeader(value = "X-Forwarded-For", required = false) xff: String?,
    @RequestHeader(value = "X-Real-IP", required = false) xri: String?
  ) {
    // honeypot
    if (!body.website.isNullOrBlank()) return

    val ip = (xff?.split(",")?.firstOrNull()?.trim()).takeUnless { it.isNullOrBlank() }
      ?: xri
      ?: "unknown"

    val now = Instant.now()
    val hits = lastHitByIp.computeIfAbsent(ip) { mutableListOf() }
    hits.removeIf { Duration.between(it, now) > window }
    if (hits.size >= maxRequests) return
    hits.add(now)

    repo.save(ContactMessageEntity(
      name = body.name,
      email = body.email,
      message = body.message
    ))
  }
}
