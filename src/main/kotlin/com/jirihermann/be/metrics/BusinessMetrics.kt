package com.jirihermann.be.metrics

import io.micrometer.core.instrument.Counter
import io.micrometer.core.instrument.DistributionSummary
import io.micrometer.core.instrument.Gauge
import io.micrometer.core.instrument.MeterRegistry
import org.springframework.stereotype.Component
import java.util.EnumMap
import java.util.concurrent.atomic.AtomicLong

/**
 * Every business meter of the backend, in one place.
 *
 * The meter names and tags are queried by the Grafana dashboard, so they are a contract: change
 * them only together with the dashboard. Tag values come from the enums below or from slugs of
 * content that exists, never from raw paths, e-mail addresses or IPs, so the number of series
 * stays bounded. Counters whose tags are a fixed set are registered up front, so every series is
 * exported (at 0) from startup.
 */
@Component
class BusinessMetrics(private val registry: MeterRegistry) {

  enum class EmailType { CONTACT_NOTIFICATION, GENERIC }
  enum class EmailResult { SENT, FAILED, DISABLED }

  enum class ContactOutcome {
    ACCEPTED, HONEYPOT, CAPTCHA_MISSING, CAPTCHA_FAILED, LOW_SCORE, ACTION_MISMATCH, HOSTNAME_MISMATCH, ERROR
  }

  /** `compile_error`: the compiler reported errors. `failed`: the program threw, or the call failed. */
  enum class PlaygroundResult { SUCCESS, COMPILE_ERROR, FAILED, DISABLED }

  enum class LearnKind { TOPIC, CHAPTER }
  enum class AdminEntity { POST, TOPIC, CHAPTER, PROJECT, TESTIMONIAL, RESUME }
  enum class AdminAction { CREATE, UPDATE, DELETE }
  enum class MediaUploadResult { SUCCESS, REJECTED, FAILED }
  enum class ContentType { POST_PUBLISHED, POST_DRAFT, TOPIC, CHAPTER, PROJECT, TESTIMONIAL }

  private val emailSent: Map<Pair<EmailType, EmailResult>, Counter> =
    EmailType.entries.flatMap { type -> EmailResult.entries.map { result -> type to result } }
      .associateWith { (type, result) ->
        registry.counter(EMAIL_SENT, "type", type.tag, "result", result.tag)
      }

  private val contactSubmissions: Map<ContactOutcome, Counter> =
    ContactOutcome.entries.associateWithTo(EnumMap(ContactOutcome::class.java)) {
      registry.counter(CONTACT_SUBMISSIONS, "outcome", it.tag)
    }

  private val recaptchaScore: DistributionSummary = DistributionSummary.builder(RECAPTCHA_SCORE)
    .description("reCAPTCHA v3 score of contact form submissions")
    .serviceLevelObjectives(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    .register(registry)

  private val playgroundExecutions: Map<PlaygroundResult, Counter> =
    PlaygroundResult.entries.associateWithTo(EnumMap(PlaygroundResult::class.java)) {
      registry.counter(PLAYGROUND_EXECUTIONS, "result", it.tag)
    }

  private val adminChanges: Map<Pair<AdminEntity, AdminAction>, Counter> =
    AdminEntity.entries.flatMap { entity -> AdminAction.entries.map { action -> entity to action } }
      .associateWith { (entity, action) ->
        registry.counter(ADMIN_CHANGES, "entity", entity.tag, "action", action.tag)
      }

  private val mediaUploads: Map<MediaUploadResult, Counter> =
    MediaUploadResult.entries.associateWithTo(EnumMap(MediaUploadResult::class.java)) {
      registry.counter(MEDIA_UPLOADS, "result", it.tag)
    }

  // Gauges read these; the refresher writes them. Held here so the gauges are never collected.
  private val openContactMessages = AtomicLong()
  private val contentItems: Map<ContentType, AtomicLong> =
    ContentType.entries.associateWithTo(EnumMap(ContentType::class.java)) { AtomicLong() }

  init {
    Gauge.builder(CONTACT_MESSAGES_OPEN, openContactMessages) { it.get().toDouble() }
      .description("Contact messages not yet handled")
      .register(registry)
    contentItems.forEach { (type, value) ->
      Gauge.builder(CONTENT_ITEMS, value) { it.get().toDouble() }
        .tag("type", type.tag)
        .description("Content items in the database")
        .register(registry)
    }
  }

  fun emailSent(type: EmailType, result: EmailResult) {
    emailSent.getValue(type to result).increment()
  }

  fun contactSubmission(outcome: ContactOutcome) {
    contactSubmissions.getValue(outcome).increment()
  }

  fun recaptchaScore(score: Double) {
    recaptchaScore.record(score)
  }

  fun playgroundExecution(result: PlaygroundResult) {
    playgroundExecutions.getValue(result).increment()
  }

  fun adminChange(entity: AdminEntity, action: AdminAction) {
    adminChanges.getValue(entity to action).increment()
  }

  fun mediaUpload(result: MediaUploadResult) {
    mediaUploads.getValue(result).increment()
  }

  /** A view of a published post; [slug] must be the slug of the post that was served. */
  fun postView(slug: String) {
    registry.counter(POST_VIEWS, "slug", slug).increment()
  }

  /**
   * A CV download. The CV endpoint renders for any slug, so slugs other than [KNOWN_CV_SLUGS]
   * are counted as `other`; [lang] is the language the CV was rendered in.
   */
  fun cvDownload(slug: String, lang: String) {
    val slugTag = if (slug in KNOWN_CV_SLUGS) slug else "other"
    registry.counter(CV_DOWNLOADS, "slug", slugTag, "lang", lang).increment()
  }

  /** A view of a Learn Kotlin topic or chapter that exists; [slug] is its id or chapter number. */
  fun learnView(kind: LearnKind, slug: String) {
    registry.counter(LEARN_VIEWS, "kind", kind.tag, "slug", slug).increment()
  }

  fun updateOpenContactMessages(count: Long) {
    openContactMessages.set(count)
  }

  fun updateContentItems(type: ContentType, count: Long) {
    contentItems.getValue(type).set(count)
  }

  companion object {
    const val EMAIL_SENT = "blog.email.sent"
    const val CONTACT_SUBMISSIONS = "blog.contact.submissions"
    const val RECAPTCHA_SCORE = "blog.recaptcha.score"
    const val CONTACT_MESSAGES_OPEN = "blog.contact.messages.open"
    const val CONTENT_ITEMS = "blog.content.items"
    const val POST_VIEWS = "blog.post.views"
    const val CV_DOWNLOADS = "blog.cv.downloads"
    const val PLAYGROUND_EXECUTIONS = "blog.playground.executions"
    const val LEARN_VIEWS = "blog.learn.views"
    const val ADMIN_CHANGES = "blog.admin.changes"
    const val MEDIA_UPLOADS = "blog.media.uploads"

    /** The CV slugs the site links to (the Resume page downloads `jirihermann`). */
    val KNOWN_CV_SLUGS: Set<String> = setOf("jirihermann")

    /** The tag value of an enum constant: `CAPTCHA_MISSING` -> `captcha_missing`. */
    private val Enum<*>.tag: String get() = name.lowercase()
  }
}
