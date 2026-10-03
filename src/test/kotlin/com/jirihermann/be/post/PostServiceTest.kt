package com.jirihermann.be.post

import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNull
import java.util.UUID
import io.mockk.coVerify
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
    coEvery { repo.findPublishedBySlug("hello") } returns entity
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
    val dto = service.getBySlug("rich", includeDrafts = true)!!
    assertEquals("An excerpt that matters for the post card.", dto.excerpt)
    assertEquals("/api/media/files/abc.gif", dto.cover_url)
    assertEquals("draft", dto.status)
  }

  @Test
  fun `should hide a draft when the reader may not preview drafts`() = runTest {
    coEvery { repo.findPublishedBySlug("secret-draft") } returns null
    assertNull(service.getBySlug("secret-draft"))
    coVerify(exactly = 0) { repo.findBySlug(any()) }
  }

  @Test
  fun `should list every status with ids when the admin lists posts`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.listAll() } returns listOf(
      PostEntity(id = id, slug = "d", title = "D", excerpt = "e", content_mdx = "c", cover_url = null, status = "draft")
    )
    val items = service.listAll()
    assertEquals(1, items.size)
    assertEquals(id, items[0].id)
    assertEquals("draft", items[0].status)
  }

  @Test
  fun `should return the id and every field when the admin opens a post`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.findBySlug("d") } returns PostEntity(
      id = id, slug = "d", title = "D", excerpt = "the excerpt", content_mdx = "c",
      cover_url = "/cover.gif", status = "draft"
    )
    val dto = service.getAdminBySlug("d")!!
    assertEquals(id, dto.id)
    assertEquals("the excerpt", dto.excerpt)
    assertEquals("/cover.gif", dto.cover_url)
  }

  @Test
  fun `should report false when updating a post that does not exist`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.findById(id) } returns null
    val req = PostService.PostUpsertRequest("s", "t", "e", "c", null, emptyList(), "draft", null)
    assertFalse(service.update(id, req))
  }
}
