package com.jirihermann.be.post

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime
import java.util.UUID

@Table("post")
data class PostEntity(
  @Id val id: UUID? = null,
  val slug: String,
  val title: String,
  val excerpt: String,
  val content_mdx: String,
  val cover_url: String?,
  val tags: List<String> = emptyList(),
  val status: String = "draft",
  val published_at: OffsetDateTime? = null,
  val updated_at: OffsetDateTime = OffsetDateTime.now()
)


