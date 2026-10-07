package com.jirihermann.be.post

import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.w3c.dom.Document
import org.w3c.dom.Element
import java.time.OffsetDateTime
import java.time.ZoneOffset
import javax.xml.parsers.DocumentBuilderFactory

class RssFeedServiceTest {
  private val repo: PostRepo = mockk()
  private val service = RssFeedService(repo)
  private val now = OffsetDateTime.of(2026, 10, 7, 12, 0, 0, 0, ZoneOffset.UTC)

  private fun post(
    slug: String,
    title: String = "Title $slug",
    excerpt: String = "Excerpt $slug",
    tags: List<String> = emptyList(),
    status: String = "published",
    publishedAt: OffsetDateTime? = now.minusDays(1),
    updatedAt: OffsetDateTime = publishedAt ?: now.minusDays(1),
  ) = PostEntity(
    slug = slug,
    title = title,
    excerpt = excerpt,
    content_mdx = "body of $slug",
    cover_url = null,
    tags = tags,
    status = status,
    published_at = publishedAt,
    updated_at = updatedAt,
  )

  private suspend fun feedOf(vararg posts: PostEntity): String {
    coEvery { repo.listFeed(now, FEED_SIZE) } returns posts.toList()
    return service.render(now).toString(Charsets.UTF_8)
  }

  private fun parse(xml: String): Document =
    DocumentBuilderFactory.newInstance().apply { isNamespaceAware = true }
      .newDocumentBuilder()
      .parse(xml.byteInputStream())

  private fun Document.channelText(name: String): String =
    (documentElement.getElementsByTagName("channel").item(0) as Element)
      .childElements().single { it.tagName == name }.textContent

  private fun Document.items(): List<Element> =
    (0 until getElementsByTagName("item").length).map { getElementsByTagName("item").item(it) as Element }

  private fun Element.childElements(): List<Element> =
    (0 until childNodes.length).map { childNodes.item(it) }.filterIsInstance<Element>()

  private fun Element.text(name: String): String = childElements().single { it.tagName == name }.textContent

  @Test
  fun `should describe the blog channel`() = runTest {
    val doc = parse(feedOf(post("a", updatedAt = now.minusHours(3))))

    assertEquals("rss", doc.documentElement.tagName)
    assertEquals("2.0", doc.documentElement.getAttribute("version"))
    assertEquals("Jiří Hermann — Blog", doc.channelText("title"))
    assertEquals("https://jirihermann.com/blog", doc.channelText("link"))
    assertEquals("Building secure tooling for AI agents", doc.channelText("description"))
    assertEquals("en", doc.channelText("language"))
    assertEquals("Wed, 7 Oct 2026 09:00:00 GMT", doc.channelText("lastBuildDate"))

    val self = doc.getElementsByTagNameNS("http://www.w3.org/2005/Atom", "link").item(0) as Element
    assertEquals("https://jirihermann.com/api/rss.xml", self.getAttribute("href"))
    assertEquals("self", self.getAttribute("rel"))
  }

  @Test
  fun `should list each post with its link, guid, date, excerpt and tags in the order given`() = runTest {
    val newer = post("newer", tags = listOf("kotlin", "security"), publishedAt = now.minusHours(1))
    val older = post("older", publishedAt = OffsetDateTime.of(2026, 9, 1, 10, 30, 0, 0, ZoneOffset.ofHours(2)))

    val items = parse(feedOf(newer, older)).items()

    assertEquals(listOf("newer", "older"), items.map { it.text("link").substringAfterLast('/') })
    val first = items[0]
    assertEquals("Title newer", first.text("title"))
    assertEquals("https://jirihermann.com/blog/newer", first.text("link"))
    assertEquals("https://jirihermann.com/blog/newer", first.text("guid"))
    assertEquals("true", first.childElements().single { it.tagName == "guid" }.getAttribute("isPermaLink"))
    assertEquals("Excerpt newer", first.text("description"))
    assertEquals(listOf("kotlin", "security"), first.childElements().filter { it.tagName == "category" }.map { it.textContent })
    assertEquals("Tue, 1 Sep 2026 08:30:00 GMT", items[1].text("pubDate"))
  }

  @Test
  fun `should escape markup in titles and excerpts`() = runTest {
    val title = "<script>alert(\"x\")</script> & \"quotes\" — 'em-dash'"
    val excerpt = "Use <b>bold</b> & Co. ]]> done"
    val xml = feedOf(post("escaped", title = title, excerpt = excerpt))

    assertFalse(xml.contains("<script>"), xml)
    assertFalse(xml.contains("<b>"), xml)
    assertTrue(xml.contains("&lt;script&gt;"), xml)
    assertTrue(xml.contains("&amp; Co."), xml)
    val item = parse(xml).items().single()
    assertEquals(title, item.text("title"))
    assertEquals(excerpt, item.text("description"))
  }

  @Test
  fun `should drop characters XML cannot carry so the feed still parses`() = runTest {
    val item = parse(feedOf(post("ctl", title = "bell\u0007 and nul\u0000 gone"))).items().single()
    assertEquals("bell and nul gone", item.text("title"))
  }

  @Test
  fun `should leave out a draft or a future post even if the query returned one`() = runTest {
    val xml = feedOf(
      post("visible"),
      post("secret-draft", title = "Secret draft", status = "draft"),
      post("scheduled", title = "Scheduled post", publishedAt = now.plusMinutes(1)),
      post("undated", title = "Undated post", publishedAt = null),
    )

    assertEquals(listOf("Title visible"), parse(xml).items().map { it.text("title") })
    assertFalse(xml.contains("secret-draft"))
    assertFalse(xml.contains("Scheduled post"))
    assertFalse(xml.contains("Undated post"))
  }

  @Test
  fun `should ask for at most twenty posts published by now`() = runTest {
    feedOf()
    coVerify(exactly = 1) { repo.listFeed(now, 20) }
  }

  @Test
  fun `should render an empty feed with the current time as its build date`() = runTest {
    val doc = parse(feedOf())
    assertTrue(doc.items().isEmpty())
    assertEquals("Wed, 7 Oct 2026 12:00:00 GMT", doc.channelText("lastBuildDate"))
  }
}
