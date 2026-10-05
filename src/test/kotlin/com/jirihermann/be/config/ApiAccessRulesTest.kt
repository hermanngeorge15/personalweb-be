package com.jirihermann.be.config

import org.junit.jupiter.api.Test
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.test.web.reactive.server.SecurityMockServerConfigurers.mockUser
import org.springframework.security.test.web.reactive.server.SecurityMockServerConfigurers.springSecurity
import org.springframework.security.web.server.WebFilterChainProxy
import org.springframework.test.web.reactive.server.WebTestClient
import org.springframework.web.reactive.function.server.RequestPredicates
import org.springframework.web.reactive.function.server.RouterFunctions
import org.springframework.web.reactive.function.server.ServerResponse

/**
 * Applies [apiAccessRules] to a minimal filter chain in front of a handler that answers 200 for
 * every path, so each status below comes from the access rules alone.
 */
class ApiAccessRulesTest {
  private val chain = ServerHttpSecurity.http()
    .csrf { it.disable() }
    .authorizeExchange { it.apiAccessRules() }
    .build()

  private val client = WebTestClient
    .bindToRouterFunction(RouterFunctions.route(RequestPredicates.all()) { ServerResponse.ok().build() })
    .webFilter<WebTestClient.RouterFunctionSpec>(WebFilterChainProxy(chain))
    .apply<WebTestClient.RouterFunctionSpec>(springSecurity())
    .build()

  private fun asRole(role: String) = client.mutateWith(mockUser().roles(role))

  @Test
  fun `should reject anonymous readers of the Kotlin admin views`() {
    client.get().uri("/api/learn-kotlin/admin/topics").exchange().expectStatus().isUnauthorized
    client.get().uri("/api/learn-kotlin/admin/topics/null-safety").exchange().expectStatus().isUnauthorized
    client.get().uri("/api/learn-kotlin/admin/chapters").exchange().expectStatus().isUnauthorized
    client.get().uri("/api/learn-kotlin/admin/chapters/1").exchange().expectStatus().isUnauthorized
  }

  @Test
  fun `should reject a signed-in non-admin reading the Kotlin admin views`() {
    asRole("PUBLISHER").get().uri("/api/learn-kotlin/admin/topics").exchange().expectStatus().isForbidden
  }

  @Test
  fun `should let an admin read the Kotlin admin views`() {
    asRole("ADMIN").get().uri("/api/learn-kotlin/admin/topics").exchange().expectStatus().isOk
    asRole("ADMIN").get().uri("/api/learn-kotlin/admin/chapters/1").exchange().expectStatus().isOk
  }

  @Test
  fun `should keep the public Kotlin course readable without signing in`() {
    client.get().uri("/api/learn-kotlin/topics").exchange().expectStatus().isOk
    client.get().uri("/api/learn-kotlin/topics/null-safety").exchange().expectStatus().isOk
    client.get().uri("/api/learn-kotlin/expense-tracker/chapters/1").exchange().expectStatus().isOk
  }

  @Test
  fun `should keep contact messages admin-only while the contact form stays public`() {
    client.get().uri("/api/contact").exchange().expectStatus().isUnauthorized
    asRole("PUBLISHER").get().uri("/api/contact").exchange().expectStatus().isForbidden
    asRole("ADMIN").get().uri("/api/contact").exchange().expectStatus().isOk
    client.post().uri("/api/contact").exchange().expectStatus().isOk
  }

  @Test
  fun `should keep the admin post list admin-only`() {
    client.get().uri("/api/admin/posts").exchange().expectStatus().isUnauthorized
    asRole("ADMIN").get().uri("/api/admin/posts").exchange().expectStatus().isOk
  }

  @Test
  fun `should let publishers write posts but not delete them`() {
    client.put().uri("/api/posts/1").exchange().expectStatus().isUnauthorized
    asRole("PUBLISHER").put().uri("/api/posts/1").exchange().expectStatus().isOk
    asRole("PUBLISHER").delete().uri("/api/posts/1").exchange().expectStatus().isForbidden
    asRole("ADMIN").delete().uri("/api/posts/1").exchange().expectStatus().isOk
  }

  @Test
  fun `should reject anonymous writes to public resources`() {
    client.post().uri("/api/projects").exchange().expectStatus().isUnauthorized
    client.put().uri("/api/learn-kotlin/topics/x").exchange().expectStatus().isUnauthorized
    client.put().uri("/api/resume/languages/x").exchange().expectStatus().isUnauthorized
  }
}
