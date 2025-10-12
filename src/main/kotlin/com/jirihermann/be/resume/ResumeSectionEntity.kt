package com.jirihermann.be.resume

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.util.UUID

@Table("resume_section")
data class ResumeSectionEntity(
  @Id val id: UUID? = null,
  val kind: String,
  val content_json: String,
  val order: Int = 0
)


