package com.jirihermann.be.contact

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime
import java.util.UUID

@Table("contact_message")
data class ContactMessageEntity(
  @Id val id: UUID? = null,
  val name: String,
  val email: String,
  val message: String,
  val created_at: OffsetDateTime = OffsetDateTime.now(),
  val handled: Boolean = false
)


