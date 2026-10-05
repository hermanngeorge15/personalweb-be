package com.jirihermann.be

import com.jirihermann.be.kotlinlearning.ChapterUpdate
import com.jirihermann.be.kotlinlearning.KotlinLearningController
import com.jirihermann.be.kotlinlearning.KotlinLearningService
import com.jirihermann.be.resume.ResumeController
import com.jirihermann.be.resume.ResumeService
import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Test
import org.springframework.http.MediaType
import org.springframework.test.web.reactive.server.WebTestClient
import java.util.UUID

/**
 * The HTTP status an admin update answers with when the service reports a missing record or a
 * refused change. PostgresWritesTest covers what the services report; this covers the mapping.
 */
class AdminUpdateStatusTest {
  private val kotlinLearning: KotlinLearningService = mockk()
  private val resume: ResumeService = mockk()
  private val client = WebTestClient
    .bindToController(KotlinLearningController(kotlinLearning, mockk()), ResumeController(resume))
    .build()

  private val topicJson = """
    {"id":"t","title":"T","module":"M","difficulty":"beginner","description":null,
     "kotlinExplanation":"E","kotlinCode":"C","readingTimeMinutes":10,"orderIndex":0,
     "partNumber":null,"partName":null,"contentStructure":"tiered","maxTierLevel":2}
  """
  private val chapterJson = """
    {"chapterNumber":1,"title":"T","description":null,"introduction":null,
     "implementationSteps":null,"codeSnippets":null,"summary":null,
     "difficulty":"beginner","estimatedTimeMinutes":30}
  """

  private fun put(uri: String, json: String) =
    client.put().uri(uri).contentType(MediaType.APPLICATION_JSON).bodyValue(json).exchange()

  @Test
  fun `should answer 404 when the Kotlin topic does not exist`() {
    coEvery { kotlinLearning.updateTopic("t", any()) } returns false
    put("/api/learn-kotlin/topics/t", topicJson).expectStatus().isNotFound
  }

  @Test
  fun `should answer 200 when the Kotlin topic is updated`() {
    coEvery { kotlinLearning.updateTopic("t", any()) } returns true
    put("/api/learn-kotlin/topics/t", topicJson).expectStatus().isOk
  }

  @Test
  fun `should answer 404, 400 or 200 for each chapter update outcome`() {
    coEvery { kotlinLearning.updateChapter(1, any()) } returns ChapterUpdate.NOT_FOUND
    put("/api/learn-kotlin/chapters/1", chapterJson).expectStatus().isNotFound

    coEvery { kotlinLearning.updateChapter(1, any()) } returns ChapterUpdate.NUMBER_CHANGED
    put("/api/learn-kotlin/chapters/1", chapterJson).expectStatus().isBadRequest

    coEvery { kotlinLearning.updateChapter(1, any()) } returns ChapterUpdate.UPDATED
    put("/api/learn-kotlin/chapters/1", chapterJson).expectStatus().isOk
  }

  @Test
  fun `should answer 404 for every resume section when the entry does not exist`() {
    val id = UUID.randomUUID()
    coEvery { resume.updateProject(id, any()) } returns false
    coEvery { resume.updateCertificate(id, any()) } returns false
    coEvery { resume.updateEducation(id, any()) } returns false
    coEvery { resume.updateLanguage(id, any()) } returns false

    put(
      "/api/resume/projects/$id",
      """{"company":"C","projectName":"P","from":"2024-01-01T00:00:00Z","until":null,"description":null,
         "responsibilities":[],"techStack":[],"repoUrl":null,"demoUrl":null}""",
    ).expectStatus().isNotFound
    put(
      "/api/resume/certificates/$id",
      """{"name":"N","issuer":"I","from":"2024-01-01T00:00:00Z","to":null,"description":null,
         "certificateId":null,"url":null}""",
    ).expectStatus().isNotFound
    put(
      "/api/resume/education/$id",
      """{"institution":"I","field":"F","degree":"D","since":"2020-01-01T00:00:00Z","expectedUntil":null,
         "thesisTitle":null,"thesisDescription":null,"status":"ongoing"}""",
    ).expectStatus().isNotFound
    put("/api/resume/languages/$id", """{"name":"Czech","level":"C2"}""").expectStatus().isNotFound
  }

  @Test
  fun `should answer 200 when a resume entry is updated`() {
    val id = UUID.randomUUID()
    coEvery { resume.updateLanguage(id, any()) } returns true
    put("/api/resume/languages/$id", """{"name":"Czech","level":"C2"}""").expectStatus().isOk
  }
}
