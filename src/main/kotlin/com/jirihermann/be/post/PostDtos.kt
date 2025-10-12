package com.jirihermann.be.post

import java.time.OffsetDateTime

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
  val content_mdx: String,
  val tags: List<String>,
  val published_at: OffsetDateTime?
)

data class PageDto<T>(
  val items: List<T>,
  val nextCursor: String?
)


