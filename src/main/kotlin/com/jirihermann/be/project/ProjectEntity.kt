package com.jirihermann.be.project

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.util.UUID

@Table("project")
data class ProjectEntity(
  @Id val id: UUID? = null,
  val slug: String,
  val title: String,
  val summary: String,
  val content_mdx: String,
  val links: String,
  val order: Int = 0
)


