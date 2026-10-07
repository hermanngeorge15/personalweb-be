package com.jirihermann.be.post

import com.jirihermann.be.tracing.withTracing
import org.springframework.stereotype.Service
import java.io.ByteArrayOutputStream
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import javax.xml.stream.XMLOutputFactory
import javax.xml.stream.XMLStreamWriter

const val RSS_FEED_PATH = "/api/rss.xml"

internal const val SITE_URL = "https://jirihermann.com"
internal const val FEED_TITLE = "Jiří Hermann — Blog"
internal const val FEED_DESCRIPTION = "Building secure tooling for AI agents"
internal const val FEED_SIZE = 20

private const val BLOG_URL = "$SITE_URL/blog"
private const val SELF_URL = "$SITE_URL$RSS_FEED_PATH"
private const val ATOM_NS = "http://www.w3.org/2005/Atom"

/**
 * The blog's RSS 2.0 feed. It holds published posts only, whoever asks: the feed takes no
 * reader identity, so signing in cannot add drafts to it.
 */
@Service
class RssFeedService(private val repo: PostRepo) {

  /** The feed as UTF-8 XML, with posts whose publication time is after [now] left out. */
  suspend fun render(now: OffsetDateTime = OffsetDateTime.now(ZoneOffset.UTC)): ByteArray = withTracing {
    // The query already selects published posts only; the filter keeps a draft out of a public,
    // cacheable response even if that query is ever changed.
    val posts = repo.listFeed(now, FEED_SIZE).filter { it.isPublicAt(now) }
    // The last time a listed post was published or edited, so the value only moves when the feed does.
    val lastBuildDate = posts.flatMap { listOfNotNull(it.published_at, it.updated_at) }.maxOrNull() ?: now
    writeRss(posts, lastBuildDate)
  }
}

private fun PostEntity.isPublicAt(now: OffsetDateTime): Boolean =
  status == "published" && published_at != null && !published_at.isAfter(now)

/** Writes the channel with a StAX writer, which escapes every text node and attribute value. */
internal fun writeRss(posts: List<PostEntity>, lastBuildDate: OffsetDateTime): ByteArray {
  val out = ByteArrayOutputStream()
  val xml = XMLOutputFactory.newFactory().createXMLStreamWriter(out, "UTF-8")
  xml.writeStartDocument("UTF-8", "1.0")
  xml.writeStartElement("rss")
  xml.writeAttribute("version", "2.0")
  xml.writeNamespace("atom", ATOM_NS)
  xml.writeStartElement("channel")
  xml.textElement("title", FEED_TITLE)
  xml.textElement("link", BLOG_URL)
  xml.textElement("description", FEED_DESCRIPTION)
  xml.textElement("language", "en")
  xml.textElement("lastBuildDate", rfc822(lastBuildDate))
  xml.writeEmptyElement("atom", "link", ATOM_NS)
  xml.writeAttribute("href", SELF_URL)
  xml.writeAttribute("rel", "self")
  xml.writeAttribute("type", "application/rss+xml")
  posts.forEach { post ->
    val link = "$BLOG_URL/${post.slug}"
    xml.writeStartElement("item")
    xml.textElement("title", post.title)
    xml.textElement("link", link)
    xml.writeStartElement("guid")
    xml.writeAttribute("isPermaLink", "true")
    xml.writeCharacters(link)
    xml.writeEndElement()
    post.published_at?.let { xml.textElement("pubDate", rfc822(it)) }
    xml.textElement("description", post.excerpt)
    post.tags.forEach { tag -> xml.textElement("category", tag) }
    xml.writeEndElement()
  }
  xml.writeEndElement() // channel
  xml.writeEndElement() // rss
  xml.writeEndDocument()
  xml.close()
  return out.toByteArray()
}

private fun XMLStreamWriter.textElement(name: String, text: String) {
  writeStartElement(name)
  writeCharacters(xmlSafe(text))
  writeEndElement()
}

/**
 * Drops characters XML 1.0 cannot carry at all, such as U+0000 or other control characters,
 * which the writer would emit verbatim and leave the document unparseable. Markup characters
 * are not touched here: the writer escapes them.
 */
private val XML_INVALID_CHARS = Regex("[^\\x09\\x0A\\x0D\\x20-\\uD7FF\\uE000-\\uFFFD\\x{10000}-\\x{10FFFF}]")

private fun xmlSafe(text: String): String = XML_INVALID_CHARS.replace(text, "")

/** RFC 822 date as RSS 2.0 expects it, in GMT, e.g. `Tue, 7 Oct 2026 08:00:00 GMT`. */
private fun rfc822(time: OffsetDateTime): String =
  DateTimeFormatter.RFC_1123_DATE_TIME.format(time.atZoneSameInstant(ZoneOffset.UTC))
