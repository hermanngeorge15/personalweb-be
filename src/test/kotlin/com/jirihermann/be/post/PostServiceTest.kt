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
}


