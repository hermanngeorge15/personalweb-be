package com.jirihermann.be.project

import java.util.UUID
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@RestController
@RequestMapping("/api/projects")
@Tag(name = "Projects")
class ProjectController(private val service: ProjectService) {
  @GetMapping
  @Operation(summary = "List projects (public)")
  suspend fun list() = service.list()

  // Admin
  @PostMapping
  @Operation(summary = "Create project", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun create(@RequestBody body: ProjectService.ProjectUpsertRequest) = mapOf("id" to service.create(body))

  @PutMapping("/{id}")
  @Operation(summary = "Update project", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun update(@PathVariable id: UUID, @RequestBody body: ProjectService.ProjectUpsertRequest) = service.update(id, body)

  @DeleteMapping("/{id}")
  @Operation(summary = "Delete project", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun delete(@PathVariable id: UUID) = service.delete(id)
}


