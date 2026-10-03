package com.jirihermann.be.auth

import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.mock.http.server.reactive.MockServerHttpRequest
import org.springframework.mock.web.server.MockServerWebExchange
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.ReactiveSecurityContextHolder
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono
import java.util.UUID

class ApiKeyAuthFilterTest {
  private val repo: ApiKeyRepo = mockk()
  private val filter = ApiKeyAuthFilter(repo)

  /** A chain that counts how often it runs and records the authentication it ran with. */
  private class RecordingChain : WebFilterChain {
    var calls = 0
    var auth: Authentication? = null
    override fun filter(exchange: org.springframework.web.server.ServerWebExchange): Mono<Void> =
      ReactiveSecurityContextHolder.getContext()
        .doOnNext { auth = it.authentication }
        .then(Mono.fromRunnable { calls++ })
  }

  private fun exchangeWithKey(key: String) =
    MockServerWebExchange.from(MockServerHttpRequest.delete("/api/posts/x").header(ApiKeyAuthFilter.HEADER, key))

  @Test
  fun `should run the chain once with an admin authentication when the key is valid`() {
    val secret = "s3cret"
    coEvery { repo.findActiveByPublicId("pub") } returns ApiKeyEntity(
      id = UUID.randomUUID(), public_id = "pub", key_hash = sha256Hex(secret), name = "test", roles = arrayOf("ADMIN")
    )
    coEvery { repo.markUsed(any()) } returns Unit
    val chain = RecordingChain()

    filter.filter(exchangeWithKey("pub.$secret"), chain).block()

    assertEquals(1, chain.calls)
    assertTrue(chain.auth!!.authorities.any { it.authority == "ROLE_ADMIN" })
  }

  @Test
  fun `should run the chain once without authentication when the key is unknown`() {
    coEvery { repo.findActiveByPublicId("nope") } returns null
    val chain = RecordingChain()

    filter.filter(exchangeWithKey("nope.whatever"), chain).block()

    assertEquals(1, chain.calls)
    assertNull(chain.auth)
  }

  @Test
  fun `should run the chain once without authentication when the secret is wrong`() {
    coEvery { repo.findActiveByPublicId("pub") } returns ApiKeyEntity(
      id = UUID.randomUUID(), public_id = "pub", key_hash = sha256Hex("right"), name = "test", roles = arrayOf("ADMIN")
    )
    val chain = RecordingChain()

    filter.filter(exchangeWithKey("pub.wrong"), chain).block()

    assertEquals(1, chain.calls)
    assertNull(chain.auth)
  }
}
