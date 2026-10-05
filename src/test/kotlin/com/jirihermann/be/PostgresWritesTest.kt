package com.jirihermann.be

import com.jirihermann.be.kotlinlearning.ChapterUpdate
import com.jirihermann.be.kotlinlearning.ExpenseTrackerChapterUpsertRequest
import com.jirihermann.be.kotlinlearning.KotlinExpenseTrackerChapterRepo
import com.jirihermann.be.kotlinlearning.KotlinLearningService
import com.jirihermann.be.kotlinlearning.KotlinTopicRepo
import com.jirihermann.be.kotlinlearning.KotlinTopicUpsertRequest
import com.jirihermann.be.project.ProjectRepo
import com.jirihermann.be.resume.ResumeService
import com.jirihermann.be.testimonial.TestimonialRepo
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotNull
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
import java.util.UUID

/**
 * Runs the hand-written write statements against a real Postgres with the production
 * migrations applied. Mocked repositories cannot catch SQL that Postgres rejects, such as
 * the unquoted reserved word `order`.
 */
@DataR2dbcTest
@Testcontainers
@Import(KotlinLearningService::class, ResumeService::class)
class PostgresWritesTest {
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

  @Autowired private lateinit var projects: ProjectRepo
  @Autowired private lateinit var testimonials: TestimonialRepo
  @Autowired private lateinit var topics: KotlinTopicRepo
  @Autowired private lateinit var chapters: KotlinExpenseTrackerChapterRepo
  @Autowired private lateinit var kotlinLearning: KotlinLearningService
  @Autowired private lateinit var resume: ResumeService

  @Test
  fun `should insert and update a project with its order and links`() = runTest {
    val slug = "p-${UUID.randomUUID()}"
    val id = projects.insert(slug, "Title", "Summary", "Body", """{"github":"x"}""", 7)

    val inserted = projects.listOrdered().single { it.id == id }
    assertEquals(7, inserted.order)
    assertTrue(inserted.links.contains("github"))

    assertEquals(1, projects.update(id, slug, "New title", "Summary", "Body", "{}", 2))
    val updated = projects.listOrdered().single { it.id == id }
    assertEquals("New title", updated.title)
    assertEquals(2, updated.order)
  }

  @Test
  fun `should update no project row when the id is unknown`() = runTest {
    assertEquals(0, projects.update(UUID.randomUUID(), "s", "t", "s", "c", "{}", 0))
  }

  @Test
  fun `should insert and update a testimonial with its order`() = runTest {
    val id = testimonials.insert("Ada", "Engineer", null, "Great work", 4)
    assertEquals(4, testimonials.listOrdered().single { it.id == id }.order)

    assertEquals(1, testimonials.update(id, "Ada", "Lead", "https://example.com/a.png", "Great work", 1))
    val updated = testimonials.listOrdered().single { it.id == id }
    assertEquals("Lead", updated.role)
    assertEquals(1, updated.order)
    assertEquals(0, testimonials.update(UUID.randomUUID(), "a", "r", null, "q", 0))
  }

  @Test
  fun `should insert a new Kotlin topic under the id the admin chose`() = runTest {
    val id = "topic-${UUID.randomUUID()}"
    val request = KotlinTopicUpsertRequest(
      id = id,
      title = "Title",
      module = "Basics",
      difficulty = "beginner",
      description = null,
      kotlinExplanation = "Explanation",
      kotlinCode = "fun main() {}",
    )

    assertEquals(id, kotlinLearning.createTopic(request))
    assertNotNull(topics.findById(id))
    assertTrue(kotlinLearning.updateTopic(id, request.copy(title = "Renamed")))
    assertEquals("Renamed", topics.findById(id)?.title)
  }

  @Test
  fun `should report a missing Kotlin topic instead of failing`() = runTest {
    val request = KotlinTopicUpsertRequest(
      id = "missing",
      title = "t",
      module = "m",
      difficulty = "beginner",
      description = null,
      kotlinExplanation = "e",
      kotlinCode = "c",
    )
    assertFalse(kotlinLearning.updateTopic("missing-${UUID.randomUUID()}", request))
  }

  @Test
  fun `should refuse to renumber a chapter and report a missing one`() = runTest {
    val chapter = chapters.findAll().first()
    val id = requireNotNull(chapter.id)
    val request = ExpenseTrackerChapterUpsertRequest(
      chapterNumber = chapter.chapter_number,
      title = chapter.title,
      description = chapter.description,
      introduction = chapter.introduction,
      implementationSteps = chapter.implementation_steps,
      codeSnippets = chapter.code_snippets,
      summary = chapter.summary,
    )

    assertEquals(ChapterUpdate.NUMBER_CHANGED, kotlinLearning.updateChapter(id, request.copy(chapterNumber = 999)))
    assertEquals(chapter.chapter_number, chapters.findById(id)?.chapter_number)
    assertEquals(ChapterUpdate.UPDATED, kotlinLearning.updateChapter(id, request.copy(title = "Retitled")))
    assertEquals(ChapterUpdate.NOT_FOUND, kotlinLearning.updateChapter(Int.MAX_VALUE, request))
  }

  @Test
  fun `should report whether a resume language existed when updating it`() = runTest {
    val id = resume.createLanguage(ResumeService.LanguageUpsertRequest("Czech", "Native"))
    assertTrue(resume.updateLanguage(id, ResumeService.LanguageUpsertRequest("Czech", "C2")))
    assertFalse(resume.updateLanguage(UUID.randomUUID(), ResumeService.LanguageUpsertRequest("x", "A1")))
  }
}
