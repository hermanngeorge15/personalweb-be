package com.jirihermann.be.post

import com.jirihermann.be.metrics.BusinessMetrics
import io.micrometer.core.instrument.simple.SimpleMeterRegistry
import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Test
import org.springframework.test.web.reactive.server.WebTestClient

class PostControllerTest {
  private val service: PostService = mockk()
  private val client = WebTestClient.bindToController(PostController(service, BusinessMetrics(SimpleMeterRegistry()))).build()

  @Test
  fun list_ok() {
    coEvery { service.list(10, null, null) } returns PageDto(
      listOf(PostListItemDto("s","t","e", emptyList(), null, null)), null
    )
    client.get().uri("/api/posts")
      .exchange()
      .expectStatus().isOk
  }
}


