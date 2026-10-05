package com.jirihermann.be.auth

import kotlinx.coroutines.reactor.mono
import org.slf4j.LoggerFactory
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.ReactiveSecurityContextHolder
import org.springframework.security.core.context.SecurityContextImpl
import org.springframework.stereotype.Component
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono
import java.util.Optional

/**
 * Resolves X-API-Key headers into a ROLE_ADMIN-bearing Authentication so
 * pipelines (e.g. blog publishing scripts) can call admin endpoints without
 * the Keycloak OAuth dance.
 *
 * Key format: "<public_id>.<secret>"
 *   public_id -> indexed lookup in api_keys
 *   secret    -> sha256 and compared to key_hash
 *
 * If the header is missing or malformed, the filter passes through untouched
 * so the downstream JWT filter / anonymous auth still run. Invalid or revoked
 * keys fall through the same way (no authentication is populated) rather
 * than short-circuiting the request — Spring Security will then 401 any
 * protected endpoint.
 */
@Component
class ApiKeyAuthFilter(
  private val apiKeyRepo: ApiKeyRepo,
) : WebFilter {
  private val logger = LoggerFactory.getLogger(ApiKeyAuthFilter::class.java)

  override fun filter(exchange: ServerWebExchange, chain: WebFilterChain): Mono<Void> {
    val raw = exchange.request.headers.getFirst(HEADER) ?: return chain.filter(exchange)
    val parts = raw.trim().split('.', limit = 2)
    if (parts.size != 2 || parts[0].isBlank() || parts[1].isBlank()) {
      return chain.filter(exchange)
    }
    val publicId = parts[0]
    val secretHash = sha256Hex(parts[1])

    // Wrap the lookup so "no such key" is a value rather than an empty Mono. The chain must run
    // exactly once: a `switchIfEmpty(chain.filter(...))` after `flatMap { chain.filter(...) }`
    // also fires when the authenticated chain completes empty (every Mono<Void> does), which
    // re-ran the whole request unauthenticated and replaced a successful response with a 401.
    return mono { apiKeyRepo.findActiveByPublicId(publicId) }
      .map { Optional.of(it) }
      .defaultIfEmpty(Optional.empty())
      .flatMap { found ->
        val entity = found.orElse(null) ?: return@flatMap chain.filter(exchange)
        if (!constantTimeEquals(entity.key_hash, secretHash)) {
          logger.debug("API key '{}' secret mismatch", publicId)
          return@flatMap chain.filter(exchange)
        }
        val authorities = entity.roles.map { SimpleGrantedAuthority("ROLE_${it.uppercase()}") }
        val auth = UsernamePasswordAuthenticationToken(
          /* principal */ "apikey:${entity.public_id}",
          /* credentials */ null,
          authorities,
        )
        val ctx = SecurityContextImpl(auth)
        // Fire-and-forget last_used_at update (don't gate request latency on it).
        entity.id?.let { id ->
          mono { apiKeyRepo.markUsed(id) }
            .doOnError { err -> logger.warn("Failed to mark api_key used: {}", err.message) }
            .subscribe()
        }
        chain.filter(exchange)
          .contextWrite(ReactiveSecurityContextHolder.withSecurityContext(Mono.just(ctx)))
      }
  }

  companion object {
    const val HEADER = "X-API-Key"

    private fun constantTimeEquals(a: String, b: String): Boolean {
      if (a.length != b.length) return false
      var diff = 0
      for (i in a.indices) diff = diff or (a[i].code xor b[i].code)
      return diff == 0
    }
  }
}
