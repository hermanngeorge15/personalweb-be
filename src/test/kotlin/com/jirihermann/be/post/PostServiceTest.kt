package com.jirihermann.be.post

import io.mockk.coEvery
import io.mockk.mockk
import java.time.OffsetDateTime
import org.junit.jupiter.api.Assertions.assertEquals
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test

class PostServiceTest {
  private val repo: PostRepo = mockk()
  private val service = PostService(repo)

  @Test
  fun list_returns_items_and_null_cursor_when_under_limit() = runTest {
    val now = OffsetDateTime.now()
    coEvery { repo.listPublished(any(), any(), any(), any()) } returns listOf(
      PostEntity(
        slug = "s1",
        title = "t1",
        excerpt = "e1",
        content_mdx = "c1",
        cover_url = null,
        tags = listOf("web"),
        status = "published",
        published_at = now
      )
    )
    val page = service.list(10, null, null)
    assertEquals(1, page.items.size)
    assertEquals(null, page.nextCursor)
  }

  @Test
  fun getBySlug_maps_detail() = runTest {
    val entity = PostEntity(
      slug = "hello",
      title = "Hello",
      excerpt = "Intro",
      content_mdx = "# Hi",
      cover_url = null,
      tags = listOf("web"),
      status = "published",
      published_at = null
    )
    coEvery { repo.findBySlug("hello") } returns entity
    val dto = service.getBySlug("hello")!!
    assertEquals("hello", dto.slug)
    assertEquals("Hello", dto.title)
  }

  @Test
  fun getBySlug_includes_excerpt_cover_and_status() = runTest {
    val entity = PostEntity(
      slug = "rich",
      title = "Rich",
      excerpt = "An excerpt that matters for the post card.",
      content_mdx = "# body",
      cover_url = "/api/media/files/abc.gif",
      tags = listOf("ai"),
      status = "draft",
      published_at = null
    )
    coEvery { repo.findBySlug("rich") } returns entity
    val dto = service.getBySlug("rich")!!
    assertEquals("An excerpt that matters for the post card.", dto.excerpt)
    assertEquals("/api/media/files/abc.gif", dto.cover_url)
    assertEquals("draft", dto.status)
  }
}


