package com.jirihermann.be.post

import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Test
import org.springframework.test.web.reactive.server.WebTestClient

class PostControllerTest {
  private val service: PostService = mockk()
  private val client = WebTestClient.bindToController(PostController(service)).build()

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


