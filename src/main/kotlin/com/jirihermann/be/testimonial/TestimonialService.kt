package com.jirihermann.be.testimonial

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
  suspend fun list(): List<TestimonialDto> = repo.listOrdered().map {
    TestimonialDto(
      author = it.author,
      role = it.role,
      avatar_url = it.avatar_url,
      quote = it.quote,
      order = it.order
    )
  }

  // Admin
  data class TestimonialUpsertRequest(
    val author: String,
    val role: String,
    val avatar_url: String?,
    val quote: String,
    val order: Int
  )

  suspend fun create(req: TestimonialUpsertRequest): UUID {
    val saved = repo.save(
      TestimonialEntity(
        author = req.author,
        role = req.role,
        avatar_url = req.avatar_url,
        quote = req.quote,
        order = req.order
      )
    )
    return saved.id!!
  }

  suspend fun update(id: UUID, req: TestimonialUpsertRequest) {
    val current = repo.findById(id) ?: return
    repo.save(
      current.copy(
        author = req.author,
        role = req.role,
        avatar_url = req.avatar_url,
        quote = req.quote,
        order = req.order
      )
    )
  }

  suspend fun delete(id: UUID) {
    repo.deleteById(id)
  }
}


