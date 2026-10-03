package com.jirihermann.be.post

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException

/** Admin reads of posts in every status. Protected by the ADMIN-only catch-all rule for /api paths in SecurityConfig. */
@RestController
@RequestMapping("/api/admin/posts")
@Tag(name = "Posts admin")
class PostAdminController(private val service: PostService) {
  @GetMapping
  @Operation(summary = "List all posts, drafts included (admin)", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun list(): List<AdminPostListItemDto> = service.listAll()

  @GetMapping("/{slug}")
  @Operation(summary = "Get any post by slug, with its id (admin)", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun get(@PathVariable slug: String): AdminPostDetailDto =
    service.getAdminBySlug(slug) ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
}
