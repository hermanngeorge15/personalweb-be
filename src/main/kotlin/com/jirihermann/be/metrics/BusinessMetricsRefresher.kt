package com.jirihermann.be.metrics

import com.jirihermann.be.contact.ContactMessageRepo
import com.jirihermann.be.kotlinlearning.KotlinExpenseTrackerChapterRepo
import com.jirihermann.be.kotlinlearning.KotlinTopicRepo
import com.jirihermann.be.metrics.BusinessMetrics.ContentType
import com.jirihermann.be.post.PostRepo
import com.jirihermann.be.project.ProjectRepo
import com.jirihermann.be.testimonial.TestimonialRepo
import kotlinx.coroutines.CancellationException
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component

/**
 * Refreshes the database-backed gauges of [BusinessMetrics] every 60 s.
 *
 * Runs as a suspending @Scheduled method (Spring runs it as a coroutine on the reactive
 * repositories, so nothing blocks). A failed query keeps the previous value and logs a warning;
 * the next run tries again. Turn it off with `business-metrics.refresh.enabled=false`.
 */
@Component
@ConditionalOnProperty("business-metrics.refresh.enabled", havingValue = "true", matchIfMissing = true)
class BusinessMetricsRefresher(
  private val metrics: BusinessMetrics,
  private val contactRepo: ContactMessageRepo,
  private val postRepo: PostRepo,
  private val topicRepo: KotlinTopicRepo,
  private val chapterRepo: KotlinExpenseTrackerChapterRepo,
  private val projectRepo: ProjectRepo,
  private val testimonialRepo: TestimonialRepo,
) {
  private val logger = LoggerFactory.getLogger(BusinessMetricsRefresher::class.java)

  @Scheduled(initialDelay = 5_000, fixedDelay = 60_000)
  suspend fun refresh() {
    refreshOne("contact.messages.open") { metrics.updateOpenContactMessages(contactRepo.countUnhandled()) }
    refreshOne("post_published") {
      metrics.updateContentItems(ContentType.POST_PUBLISHED, postRepo.countByStatus("published"))
    }
    refreshOne("post_draft") { metrics.updateContentItems(ContentType.POST_DRAFT, postRepo.countByStatus("draft")) }
    refreshOne("topic") { metrics.updateContentItems(ContentType.TOPIC, topicRepo.count()) }
    refreshOne("chapter") { metrics.updateContentItems(ContentType.CHAPTER, chapterRepo.count()) }
    refreshOne("project") { metrics.updateContentItems(ContentType.PROJECT, projectRepo.count()) }
    refreshOne("testimonial") { metrics.updateContentItems(ContentType.TESTIMONIAL, testimonialRepo.count()) }
  }

  private suspend fun refreshOne(name: String, update: suspend () -> Unit) {
    try {
      update()
    } catch (e: CancellationException) {
      throw e
    } catch (e: Exception) {
      logger.warn("Could not refresh business metric {}: {}", name, e.message)
    }
  }
}

@Configuration
@EnableScheduling
class SchedulingConfig
