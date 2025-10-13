package com.jirihermann.be.testimonial

import com.jirihermann.be.tracing.withTracing
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.UUID

data class TestimonialDto(
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
    val order: Int
  )

  suspend fun create(req: TestimonialUpsertRequest): UUID = withTracing {
    logger.info("Creating testimonial: author={}", req.author)
    val saved = repo.save(
      TestimonialEntity(
        author = req.author,
        role = req.role,
        avatar_url = req.avatar_url,
        quote = req.quote,
        order = req.order
      )
    )
    logger.info("Testimonial created: id={}, author={}", saved.id, saved.author)
    saved.id!!
  }

  suspend fun update(id: UUID, req: TestimonialUpsertRequest): Unit = withTracing {
    logger.info("Updating testimonial: id={}, author={}", id, req.author)
    val current = repo.findById(id)
    if (current == null) {
      logger.warn("Testimonial not found for update: id={}", id)
      return@withTracing
    }
    repo.save(
      current.copy(
        author = req.author,
        role = req.role,
        avatar_url = req.avatar_url,
        quote = req.quote,
        order = req.order
      )
    )
    logger.info("Testimonial updated: id={}, author={}", id, req.author)
  }

  suspend fun delete(id: UUID): Unit = withTracing {
    logger.info("Deleting testimonial: id={}", id)
    repo.deleteById(id)
    logger.info("Testimonial deleted: id={}", id)
  }
}


