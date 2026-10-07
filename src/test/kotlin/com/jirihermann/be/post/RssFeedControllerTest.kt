package com.jirihermann.be.post

import com.jirihermann.be.config.apiAccessRules
import com.jirihermann.be.tracing.TracingWebFilter
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.confirmVerified
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.test.web.reactive.server.SecurityMockServerConfigurers.mockUser
import org.springframework.security.test.web.reactive.server.SecurityMockServerConfigurers.springSecurity
import org.springframework.security.web.server.WebFilterChainProxy
import org.springframework.test.web.reactive.server.WebTestClient
import java.time.OffsetDateTime

/**
 * The feed endpoint behind the production tracing filter, access rules and Spring Security's
 * default response headers, with only the database mocked.
 */
class RssFeedControllerTest {
  private val repo: PostRepo = mockk()

  private val chain = ServerHttpSecurity.http()
    .csrf { it.disable() }
    .authorizeExchange { it.apiAccessRules() }
    .build()

  private val client = WebTestClient
    .bindToController(RssFeedController(RssFeedService(repo)))
    .webFilter<WebTestClient.ControllerSpec>(TracingWebFilter(), WebFilterChainProxy(chain))
    .apply<WebTestClient.ControllerSpec>(springSecurity())
    .build()

  private val published = PostEntity(
    slug = "hello-feed",
    title = "Hello <feed> & friends",
    excerpt = "A published post",
    content_mdx = "body",
    cover_url = null,
    tags = listOf("kotlin"),
    status = "published",
    published_at = OffsetDateTime.now().minusDays(1),
  )

  private fun body(spec: WebTestClient.ResponseSpec): String =
    String(requireNotNull(spec.expectBody().returnResult().responseBody), Charsets.UTF_8)

  @Test
  fun `should serve the feed to an anonymous reader as cacheable RSS`() {
    coEvery { repo.listFeed(any(), FEED_SIZE) } returns listOf(published)

    val response = client.get().uri("/api/rss.xml").exchange()
      .expectStatus().isOk
      .expectHeader().contentType("application/rss+xml;charset=UTF-8")
      .expectHeader().valueEquals(HttpHeaders.CACHE_CONTROL, "public, max-age=900")

    val xml = body(response)
    assertTrue(xml.contains("<title>Hello &lt;feed&gt; &amp; friends</title>"), xml)
    assertTrue(xml.contains("<link>https://jirihermann.com/blog/hello-feed</link>"), xml)
  }

  @Test
  fun `should give a signed-in admin the same published-only feed`() {
    coEvery { repo.listFeed(any(), FEED_SIZE) } returns listOf(published)

    val xml = body(client.mutateWith(mockUser().roles("ADMIN")).get().uri("/api/rss.xml").exchange().expectStatus().isOk)

    assertTrue(xml.contains("hello-feed"), xml)
    // Signing in must not switch the feed to a query that can return drafts.
    coVerify(exactly = 1) { repo.listFeed(any(), FEED_SIZE) }
    confirmVerified(repo)
  }

  @Test
  fun `should keep a draft out of the feed for an admin even if the query returned one`() {
    val draft = published.copy(slug = "secret-draft", title = "Secret draft", status = "draft")
    coEvery { repo.listFeed(any(), FEED_SIZE) } returns listOf(published, draft)

    val xml = body(client.mutateWith(mockUser().roles("ADMIN")).get().uri("/api/rss.xml").exchange().expectStatus().isOk)

    assertFalse(xml.contains("secret-draft"), xml)
    assertFalse(xml.contains("Secret draft"), xml)
  }

  @Test
  fun `should not accept writes to the feed path`() {
    client.post().uri("/api/rss.xml").exchange().expectStatus().isUnauthorized
    client.mutateWith(mockUser().roles("PUBLISHER")).delete().uri("/api/rss.xml").exchange().expectStatus().isForbidden
  }
}
