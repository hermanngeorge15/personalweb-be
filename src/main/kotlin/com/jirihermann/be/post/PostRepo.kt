package com.jirihermann.be.post

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface PostRepo : CoroutineCrudRepository<PostEntity, UUID> {
  @Query(
    """
    select * from post
    where status = 'published'
      and (:tag is null or :tag = any(tags))
      and (
        :cursor_published_at is null or
        published_at < :cursor_published_at or
        (published_at = :cursor_published_at and slug > :cursor_slug)
      )
    order by published_at desc nulls last, slug asc
    limit :limit
    """
  )
  suspend fun listPublished(limit: Int, tag: String?, cursor_published_at: java.time.OffsetDateTime?, cursor_slug: String?): List<PostEntity>

  /** Any status. Admin reads and upsert-by-slug only — never for anonymous readers. */
  @Query("""select * from post where slug = :slug and status in ('published','draft')""")
  suspend fun findBySlug(slug: String): PostEntity?

  @Query("""select * from post where slug = :slug and status = 'published'""")
  suspend fun findPublishedBySlug(slug: String): PostEntity?

  /** Every post, drafts included, newest first. Admin list. */
  @Query("""select * from post order by coalesce(published_at, updated_at) desc, slug asc""")
  suspend fun listAll(): List<PostEntity>
}


