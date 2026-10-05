package com.jirihermann.be.post

import java.time.OffsetDateTime
import java.util.UUID

data class PostListItemDto(
  val slug: String,
  val title: String,
  val excerpt: String,
  val tags: List<String>,
  val published_at: OffsetDateTime?,
  val cover_url: String?
)

data class PostDetailDto(
  val slug: String,
  val title: String,
  val excerpt: String,
  val content_mdx: String,
  val cover_url: String?,
  val tags: List<String>,
  val status: String,
  val published_at: OffsetDateTime?
)

/** Admin list row: every status, with the id the admin needs to update or delete. */
data class AdminPostListItemDto(
  val id: UUID,
  val slug: String,
  val title: String,
  val excerpt: String,
  val tags: List<String>,
  val status: String,
  val published_at: OffsetDateTime?,
  val updated_at: OffsetDateTime
)

/** Admin edit form: the full post plus its id. */
data class AdminPostDetailDto(
  val id: UUID,
  val slug: String,
  val title: String,
  val excerpt: String,
  val content_mdx: String,
  val cover_url: String?,
  val tags: List<String>,
  val status: String,
  val published_at: OffsetDateTime?,
  val updated_at: OffsetDateTime
)

data class PageDto<T>(
  val items: List<T>,
  val nextCursor: String?
)


