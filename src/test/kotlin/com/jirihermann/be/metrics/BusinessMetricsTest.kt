package com.jirihermann.be.metrics

import com.jirihermann.be.metrics.BusinessMetrics.AdminAction
import com.jirihermann.be.metrics.BusinessMetrics.AdminEntity
import com.jirihermann.be.metrics.BusinessMetrics.ContactOutcome
import com.jirihermann.be.metrics.BusinessMetrics.ContentType
import com.jirihermann.be.metrics.BusinessMetrics.EmailResult
import com.jirihermann.be.metrics.BusinessMetrics.EmailType
import com.jirihermann.be.metrics.BusinessMetrics.LearnKind
import com.jirihermann.be.metrics.BusinessMetrics.MediaUploadResult
import com.jirihermann.be.metrics.BusinessMetrics.PlaygroundResult
import io.micrometer.core.instrument.simple.SimpleMeterRegistry
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.EnumSource
import org.junit.jupiter.params.provider.ValueSource

class BusinessMetricsTest {
  private val registry = SimpleMeterRegistry()
  private val metrics = BusinessMetrics(registry)

  private fun count(name: String, vararg tags: String): Double =
    registry.get(name).tags(*tags).counter().count()

  /** Sum of every series of [name]: proves an increment landed on exactly one series. */
  private fun total(name: String): Double = registry.find(name).counters().sumOf { it.count() }

  @Test
  fun `should export every fixed-tag counter at zero from startup`() {
    assertEquals(6, registry.find(BusinessMetrics.EMAIL_SENT).counters().size)
    assertEquals(8, registry.find(BusinessMetrics.CONTACT_SUBMISSIONS).counters().size)
    assertEquals(4, registry.find(BusinessMetrics.PLAYGROUND_EXECUTIONS).counters().size)
    assertEquals(18, registry.find(BusinessMetrics.ADMIN_CHANGES).counters().size)
    assertEquals(3, registry.find(BusinessMetrics.MEDIA_UPLOADS).counters().size)
    assertEquals(0.0, total(BusinessMetrics.EMAIL_SENT))
  }

  @ParameterizedTest
  @EnumSource(EmailType::class)
  fun `should count each email result under its type and result tags`(type: EmailType) {
    metrics.emailSent(type, EmailResult.SENT)
    metrics.emailSent(type, EmailResult.FAILED)
    metrics.emailSent(type, EmailResult.FAILED)
    metrics.emailSent(type, EmailResult.DISABLED)

    val typeTag = type.name.lowercase()
    assertEquals(1.0, count(BusinessMetrics.EMAIL_SENT, "type", typeTag, "result", "sent"))
    assertEquals(2.0, count(BusinessMetrics.EMAIL_SENT, "type", typeTag, "result", "failed"))
    assertEquals(1.0, count(BusinessMetrics.EMAIL_SENT, "type", typeTag, "result", "disabled"))
    assertEquals(4.0, total(BusinessMetrics.EMAIL_SENT))
  }

  @ParameterizedTest
  @EnumSource(ContactOutcome::class)
  fun `should count each contact outcome under its own tag only`(outcome: ContactOutcome) {
    metrics.contactSubmission(outcome)

    assertEquals(1.0, count(BusinessMetrics.CONTACT_SUBMISSIONS, "outcome", outcome.name.lowercase()))
    assertEquals(1.0, total(BusinessMetrics.CONTACT_SUBMISSIONS))
  }

  @Test
  fun `should use the dashboard's tag values for contact outcomes`() {
    val tags = registry.find(BusinessMetrics.CONTACT_SUBMISSIONS).counters().map { it.id.getTag("outcome") }.toSet()
    assertEquals(
      setOf(
        "accepted", "honeypot", "captcha_missing", "captcha_failed", "low_score",
        "action_mismatch", "hostname_mismatch", "error",
      ),
      tags,
    )
  }

  @ParameterizedTest
  @EnumSource(PlaygroundResult::class)
  fun `should count each playground result under its own tag only`(result: PlaygroundResult) {
    metrics.playgroundExecution(result)

    assertEquals(1.0, count(BusinessMetrics.PLAYGROUND_EXECUTIONS, "result", result.name.lowercase()))
    assertEquals(1.0, total(BusinessMetrics.PLAYGROUND_EXECUTIONS))
  }

  @ParameterizedTest
  @EnumSource(AdminEntity::class)
  fun `should count each admin action under its entity and action tags`(entity: AdminEntity) {
    AdminAction.entries.forEach { metrics.adminChange(entity, it) }

    AdminAction.entries.forEach { action ->
      assertEquals(
        1.0,
        count(BusinessMetrics.ADMIN_CHANGES, "entity", entity.name.lowercase(), "action", action.name.lowercase()),
      )
    }
    assertEquals(3.0, total(BusinessMetrics.ADMIN_CHANGES))
  }

  @ParameterizedTest
  @EnumSource(MediaUploadResult::class)
  fun `should count each media upload result under its own tag only`(result: MediaUploadResult) {
    metrics.mediaUpload(result)

    assertEquals(1.0, count(BusinessMetrics.MEDIA_UPLOADS, "result", result.name.lowercase()))
    assertEquals(1.0, total(BusinessMetrics.MEDIA_UPLOADS))
  }

  @Test
  fun `should record recaptcha scores with the service level objective buckets`() {
    listOf(0.9, 0.3, 0.7).forEach(metrics::recaptchaScore)

    val summary = registry.get(BusinessMetrics.RECAPTCHA_SCORE).summary()
    assertEquals(3, summary.count())
    assertEquals(1.9, summary.totalAmount(), 1e-9)
    val buckets = summary.takeSnapshot().histogramCounts().map { it.bucket() }.sorted()
    assertEquals(listOf(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0), buckets)
  }

  @Test
  fun `should count post views per slug`() {
    metrics.postView("injection-scanner")
    metrics.postView("injection-scanner")
    metrics.postView("secure-web")

    assertEquals(2.0, count(BusinessMetrics.POST_VIEWS, "slug", "injection-scanner"))
    assertEquals(1.0, count(BusinessMetrics.POST_VIEWS, "slug", "secure-web"))
  }

  @Test
  fun `should count unknown cv slugs as other so the series stay bounded`() {
    metrics.cvDownload("jirihermann", "en")
    metrics.cvDownload("anything-an-attacker-types", "en")
    metrics.cvDownload("another-one", "cs")

    assertEquals(1.0, count(BusinessMetrics.CV_DOWNLOADS, "slug", "jirihermann", "lang", "en"))
    assertEquals(1.0, count(BusinessMetrics.CV_DOWNLOADS, "slug", "other", "lang", "en"))
    assertEquals(1.0, count(BusinessMetrics.CV_DOWNLOADS, "slug", "other", "lang", "cs"))
    assertNull(registry.find(BusinessMetrics.CV_DOWNLOADS).tag("slug", "another-one").counter())
  }

  @Test
  fun `should count learn views per kind and slug`() {
    metrics.learnView(LearnKind.TOPIC, "null-safety")
    metrics.learnView(LearnKind.CHAPTER, "3")

    assertEquals(1.0, count(BusinessMetrics.LEARN_VIEWS, "kind", "topic", "slug", "null-safety"))
    assertEquals(1.0, count(BusinessMetrics.LEARN_VIEWS, "kind", "chapter", "slug", "3"))
  }

  @Test
  fun `should report the latest database counts through the gauges`() {
    metrics.updateOpenContactMessages(4)
    metrics.updateContentItems(ContentType.POST_PUBLISHED, 12)
    metrics.updateContentItems(ContentType.POST_DRAFT, 3)
    metrics.updateContentItems(ContentType.POST_PUBLISHED, 13)

    assertEquals(4.0, registry.get(BusinessMetrics.CONTACT_MESSAGES_OPEN).gauge().value())
    assertEquals(13.0, registry.get(BusinessMetrics.CONTENT_ITEMS).tag("type", "post_published").gauge().value())
    assertEquals(3.0, registry.get(BusinessMetrics.CONTENT_ITEMS).tag("type", "post_draft").gauge().value())
    assertEquals(0.0, registry.get(BusinessMetrics.CONTENT_ITEMS).tag("type", "testimonial").gauge().value())
    assertEquals(
      setOf("post_published", "post_draft", "topic", "chapter", "project", "testimonial"),
      registry.find(BusinessMetrics.CONTENT_ITEMS).gauges().map { it.id.getTag("type") }.toSet(),
    )
  }

  @ParameterizedTest
  @ValueSource(
    strings = [
      "Googlebot/2.1 (+http://www.google.com/bot.html)", "curl/8.4.0", "python-requests/2.31",
      "facebookexternalhit/1.1", "Mozilla/5.0 (compatible; bingbot/2.0)", "Go-http-client/1.1",
      "Mozilla/5.0 HeadlessChrome/120.0", " ",
    ]
  )
  fun `should treat crawlers, link previewers and http libraries as bots`(userAgent: String) {
    assertTrue(isLikelyBot(userAgent))
  }

  @Test
  fun `should treat a missing user agent as a bot and a browser as a reader`() {
    assertTrue(isLikelyBot(null))
    assertFalse(
      isLikelyBot("Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15")
    )
  }
}
