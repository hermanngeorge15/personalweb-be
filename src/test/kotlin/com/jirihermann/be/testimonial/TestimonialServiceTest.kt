package com.jirihermann.be.testimonial

import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test
import java.util.UUID

class TestimonialServiceTest {
  private val repo: TestimonialRepo = mockk()
  private val service = TestimonialService(repo)

  @Test
  fun `should default the order to 0 when it is not given`() {
    val req = TestimonialService.TestimonialUpsertRequest(author = "A", role = "R", avatar_url = null, quote = "Q")
    assertEquals(0, req.order)
  }

  @Test
  fun `should insert through the explicit statement when creating a testimonial`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.insert("A", "R", null, "Q", 0) } returns id
    val req = TestimonialService.TestimonialUpsertRequest(author = "A", role = "R", avatar_url = null, quote = "Q")
    assertEquals(id, service.create(req))
    coVerify(exactly = 0) { repo.save(any()) }
  }

  @Test
  fun `should report false when updating a testimonial that does not exist`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.update(id, any(), any(), any(), any(), any()) } returns 0
    val req = TestimonialService.TestimonialUpsertRequest("A", "R", null, "Q", 1)
    assertFalse(service.update(id, req))
  }

  @Test
  fun `should expose the id when listing testimonials`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.listOrdered() } returns listOf(TestimonialEntity(id, "A", "R", null, "Q", 0))
    assertEquals(id, service.list().single().id)
  }
}
