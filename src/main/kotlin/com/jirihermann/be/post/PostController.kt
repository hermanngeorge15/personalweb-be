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
  @Operation(summary = "Get post by slug (public)")
  suspend fun get(@PathVariable slug: String) =
    service.getBySlug(slug) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)

  // Admin
  @PostMapping
  @Operation(summary = "Create post", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun create(@RequestBody body: PostService.PostUpsertRequest) = mapOf("id" to service.create(body))

  @PutMapping("/{id}")
  @Operation(summary = "Update post", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun update(@PathVariable id: UUID, @RequestBody body: PostService.PostUpsertRequest) = service.update(id, body)

  @DeleteMapping("/{id}")
  @Operation(summary = "Delete post", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun delete(@PathVariable id: UUID) = service.delete(id)
}


