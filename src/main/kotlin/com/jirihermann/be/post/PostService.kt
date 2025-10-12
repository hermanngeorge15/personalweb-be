package com.jirihermann.be.post

import org.springframework.stereotype.Service
import java.time.OffsetDateTime
import java.util.UUID

@Service
class PostService(private val repo: PostRepo) {
  suspend fun list(limit: Int, tag: String?, cursor: String?): PageDto<PostListItemDto> {
    val (cursorPublishedAt, cursorSlug) = decodeCursor(cursor)
    val entities = repo.listPublished(limit + 1, tag, cursorPublishedAt, cursorSlug)
    val items = entities.take(limit).map {
      PostListItemDto(
        slug = it.slug,
        title = it.title,
        excerpt = it.excerpt,
        tags = it.tags,
        published_at = it.published_at,
        cover_url = it.cover_url
      )
    }
    val nextCursor = if (entities.size > limit) encodeCursor(items.last().published_at, items.last().slug) else null
    return PageDto(items = items, nextCursor = nextCursor)
  }

  suspend fun getBySlug(slug: String): PostDetailDto? = repo.findBySlug(slug)?.let {
    PostDetailDto(
      slug = it.slug,
      title = it.title,
      content_mdx = it.content_mdx,
      tags = it.tags,
      published_at = it.published_at
    )
  }

  // Admin
  data class PostUpsertRequest(
    val slug: String,
    val title: String,
    val excerpt: String,
    val content_mdx: String,
    val cover_url: String?,
    val tags: List<String> = emptyList(),
    val status: String = "draft",
    val published_at: OffsetDateTime?
  )

  suspend fun create(req: PostUpsertRequest): UUID {
    val saved = repo.save(
      PostEntity(
        slug = req.slug,
        title = req.title,
        excerpt = req.excerpt,
        content_mdx = req.content_mdx,
        cover_url = req.cover_url,
        tags = req.tags,
        status = req.status,
        published_at = req.published_at
      )
    )
    return saved.id!!
  }

  suspend fun update(id: UUID, req: PostUpsertRequest) {
    val current = repo.findById(id) ?: return
    repo.save(
      current.copy(
        slug = req.slug,
        title = req.title,
        excerpt = req.excerpt,
        content_mdx = req.content_mdx,
        cover_url = req.cover_url,
        tags = req.tags,
        status = req.status,
        published_at = req.published_at
      )
    )
  }

  suspend fun delete(id: UUID) {
    repo.deleteById(id)
  }
}

private fun encodeCursor(publishedAt: OffsetDateTime?, slug: String): String? {
  if (publishedAt == null) return null
  val raw = publishedAt.toString() + "|" + slug
  return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(raw.toByteArray())
}

private fun decodeCursor(cursor: String?): Pair<OffsetDateTime?, String?> {
  if (cursor.isNullOrBlank()) return Pair(null, null)
  return try {
    val decoded = String(java.util.Base64.getUrlDecoder().decode(cursor))
    val parts = decoded.split("|", limit = 2)
    if (parts.size == 2) Pair(OffsetDateTime.parse(parts[0]), parts[1]) else Pair(null, null)
  } catch (e: Exception) {
    Pair(null, null)
  }
}


