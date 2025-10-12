package com.jirihermann.be.contact

import java.util.UUID
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.http.HttpStatus
import kotlinx.coroutines.flow.toList
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/contact")
@Tag(name = "Contact Admin")
class ContactAdminController(private val repo: ContactMessageRepo) {
  @GetMapping
  @Operation(summary = "List contact messages", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun list(@org.springframework.web.bind.annotation.RequestParam(required = false) handled: Boolean?): List<ContactMessageEntity> =
    if (handled == false) repo.listUnHandled() else repo.findAll().toList(mutableListOf())

  @PostMapping("/{id}:handle")
  @Operation(summary = "Mark contact message handled", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun handle(@PathVariable id: UUID) {
    val msg = repo.findById(id) ?: return
    repo.save(msg.copy(handled = true))
  }
}


