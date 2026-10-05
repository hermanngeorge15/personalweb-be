package com.jirihermann.be.post

import java.util.UUID
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.server.ResponseStatusException
import org.springframework.http.server.reactive.ServerHttpResponse
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.ReactiveSecurityContextHolder
import kotlinx.coroutines.reactor.awaitSingleOrNull

@RestController
@RequestMapping("/api/posts")
@Tag(name = "Posts")
class PostController(private val service: PostService) {
  @GetMapping
  @Operation(summary = "List posts (public)")
  suspend fun list(
    @RequestParam(required = false) limit: Int?,
    @RequestParam(required = false) tag: String?,
    @RequestParam(required = false) cursor: String?
  ) = service.list(limit ?: 10, tag, cursor)

  @GetMapping("/{slug}")
  @Operation(summary = "Get post by slug (public). Drafts only for a signed-in admin or publisher.")
  suspend fun get(@PathVariable slug: String, response: ServerHttpResponse): PostDetailDto {
    val includeDrafts = canPreviewDrafts(currentAuthentication())
    val post = service.getBySlug(slug, includeDrafts) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    // A draft is personal to the signed-in reader: never let a shared cache keep it.
    if (post.status != "published") response.headers.cacheControl = "private, no-store"
    return post
  }

  // Admin
  @PostMapping
  @Operation(summary = "Create post", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun create(@RequestBody body: PostService.PostUpsertRequest) = mapOf("id" to service.create(body))

  @PutMapping("/{id}")
  @Operation(summary = "Update post", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun update(@PathVariable id: UUID, @RequestBody body: PostService.PostUpsertRequest) {
    if (!service.update(id, body)) throw ResponseStatusException(HttpStatus.NOT_FOUND)
  }

  @PutMapping("/by-slug/{slug}")
  @Operation(
    summary = "Upsert post by slug (admin). Creates on missing, replaces on existing.",
    security = [SecurityRequirement(name = "bearer-jwt")]
  )
  suspend fun upsertBySlug(
    @PathVariable slug: String,
    @RequestBody body: PostService.PostUpsertRequest,
  ): PostService.UpsertResult = service.upsertBySlug(slug, body)

  @DeleteMapping("/{id}")
  @Operation(summary = "Delete post", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun delete(@PathVariable id: UUID) = service.delete(id)
}

private val DRAFT_READER_ROLES = setOf("ROLE_ADMIN", "ROLE_PUBLISHER")

/** True when [auth] is a signed-in admin or publisher, who may read drafts by slug. */
internal fun canPreviewDrafts(auth: Authentication?): Boolean =
  auth != null && auth.isAuthenticated && auth.authorities.any { it.authority in DRAFT_READER_ROLES }

private suspend fun currentAuthentication(): Authentication? =
  ReactiveSecurityContextHolder.getContext().awaitSingleOrNull()?.authentication
