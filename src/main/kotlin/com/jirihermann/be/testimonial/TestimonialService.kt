package com.jirihermann.be.testimonial

import com.jirihermann.be.tracing.withTracing
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.UUID

data class TestimonialDto(
  val id: UUID?,
  val author: String,
  val role: String,
  val avatar_url: String?,
  val quote: String,
  val order: Int
)

@Service
class TestimonialService(private val repo: TestimonialRepo) {
  private val logger = LoggerFactory.getLogger(TestimonialService::class.java)

  suspend fun list(): List<TestimonialDto> = withTracing {
    logger.info("Listing testimonials")
    val testimonials = repo.listOrdered().map {
      TestimonialDto(
        id = it.id,
        author = it.author,
        role = it.role,
        avatar_url = it.avatar_url,
        quote = it.quote,
        order = it.order
      )
    }
    logger.info("Listed {} testimonials", testimonials.size)
    testimonials
  }

  // Admin
  data class TestimonialUpsertRequest(
    val author: String,
    val role: String,
    val avatar_url: String?,
    val quote: String,
    val order: Int = 0
  )

  suspend fun create(req: TestimonialUpsertRequest): UUID = withTracing {
    logger.info("Creating testimonial: author={}", req.author)
    val id = repo.insert(req.author, req.role, req.avatar_url, req.quote, req.order)
    logger.info("Testimonial created: id={}, author={}", id, req.author)
    id
  }

  /** Replaces the testimonial with [id]. Returns false when no such testimonial exists. */
  suspend fun update(id: UUID, req: TestimonialUpsertRequest): Boolean = withTracing {
    logger.info("Updating testimonial: id={}, author={}", id, req.author)
    val updated = repo.update(id, req.author, req.role, req.avatar_url, req.quote, req.order) > 0
    if (!updated) logger.warn("Testimonial not found for update: id={}", id)
    updated
  }

  suspend fun delete(id: UUID): Unit = withTracing {
    logger.info("Deleting testimonial: id={}", id)
    repo.deleteById(id)
    logger.info("Testimonial deleted: id={}", id)
  }
}


