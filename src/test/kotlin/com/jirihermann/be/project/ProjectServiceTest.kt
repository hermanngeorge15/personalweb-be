package com.jirihermann.be.project

import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.util.UUID

class ProjectServiceTest {
  private val repo: ProjectRepo = mockk()
  private val service = ProjectService(repo)
  private val req = ProjectService.ProjectUpsertRequest("slug", "Title", "Summary", "Body", """{"github":"x"}""", 3)

  @Test
  fun `should insert through the explicit statement when creating a project`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.insert("slug", "Title", "Summary", "Body", """{"github":"x"}""", 3) } returns id
    assertEquals(id, service.create(req))
    coVerify(exactly = 0) { repo.save(any()) }
  }

  @Test
  fun `should report true when an existing project is updated`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.update(id, "slug", "Title", "Summary", "Body", """{"github":"x"}""", 3) } returns 1
    assertTrue(service.update(id, req))
  }

  @Test
  fun `should report false when updating a project that does not exist`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.update(id, any(), any(), any(), any(), any(), any()) } returns 0
    assertFalse(service.update(id, req))
  }

  @Test
  fun `should expose the id when listing projects`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.listOrdered() } returns listOf(ProjectEntity(id, "s", "t", "sum", "c", "{}", 0))
    assertEquals(id, service.list().single().id)
  }
}
