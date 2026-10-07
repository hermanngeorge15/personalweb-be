package com.jirihermann.be.post

import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.data.r2dbc.DataR2dbcTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

/**
 * Runs the feed query against a real Postgres with the production migrations applied, so the
 * proof that drafts stay out covers the SQL itself and not a mocked repository.
 */
@DataR2dbcTest
@Testcontainers
@Import(RssFeedService::class)
class RssFeedQueryTest {
  companion object {
    @Container
    @JvmStatic
    val postgres = PostgreSQLContainer<Nothing>("postgres:16-alpine").apply {
      withDatabaseName("personal")
      withUsername("personal")
      withPassword("personal")
    }

    @DynamicPropertySource
    @JvmStatic
    fun databaseProperties(registry: DynamicPropertyRegistry) {
      registry.add("spring.r2dbc.url") {
        "r2dbc:postgresql://${postgres.host}:${postgres.firstMappedPort}/${postgres.databaseName}"
      }
      registry.add("spring.r2dbc.username") { postgres.username }
      registry.add("spring.r2dbc.password") { postgres.password }
      registry.add("spring.flyway.url") { postgres.jdbcUrl }
      registry.add("spring.flyway.user") { postgres.username }
      registry.add("spring.flyway.password") { postgres.password }
    }
  }

  @Autowired private lateinit var posts: PostRepo
  @Autowired private lateinit var feed: RssFeedService

  private val now = OffsetDateTime.now(ZoneOffset.UTC)

  private suspend fun save(slug: String, status: String, publishedAt: OffsetDateTime?) = posts.save(
    PostEntity(
      slug = slug,
      title = "Title of $slug",
      excerpt = "Excerpt of $slug",
      content_mdx = "body",
      cover_url = null,
      tags = listOf("kotlin"),
      status = status,
      published_at = publishedAt,
    )
  )

  @Test
  fun `should list only published posts that are due, newest first`() = runTest {
    val run = UUID.randomUUID().toString().take(8)
    save("old-$run", "published", now.minusDays(10))
    save("new-$run", "published", now.minusDays(1))
    save("draft-$run", "draft", now.minusDays(2))
    save("draft-undated-$run", "draft", null)
    save("scheduled-$run", "published", now.plusDays(1))
    save("undated-$run", "published", null)

    val slugs = posts.listFeed(now, FEED_SIZE).map { it.slug }.filter { it.endsWith(run) }

    assertEquals(listOf("new-$run", "old-$run"), slugs)
  }

  @Test
  fun `should keep an existing draft out of the rendered feed`() = runTest {
    val run = UUID.randomUUID().toString().take(8)
    save("visible-$run", "published", now.minusHours(1))
    save("secret-draft-$run", "draft", now.minusHours(2))

    val xml = feed.render(now).toString(Charsets.UTF_8)

    assertTrue(xml.contains("https://jirihermann.com/blog/visible-$run"), xml)
    assertFalse(xml.contains("secret-draft-$run"), xml)
  }

  @Test
  fun `should cap the feed at twenty posts`() = runTest {
    val run = UUID.randomUUID().toString().take(8)
    repeat(FEED_SIZE + 3) { save("bulk-$it-$run", "published", now.minusMinutes(it + 1L)) }

    assertEquals(FEED_SIZE, posts.listFeed(now, FEED_SIZE).size)
  }
}
