package com.jirihermann.be.testimonial

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.util.UUID

@Table("testimonial")
data class TestimonialEntity(
  @Id val id: UUID? = null,
  val author: String,
  val role: String,
  val avatar_url: String?,
  val quote: String,
  val order: Int = 0
)


