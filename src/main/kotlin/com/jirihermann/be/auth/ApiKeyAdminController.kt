package com.jirihermann.be.auth

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import kotlinx.coroutines.flow.toList
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

/**
 * Admin HTTP API for minting, listing, and revoking api keys.
 *
 * Protected by the global /api route rule in SecurityConfig which requires
 * `ROLE_ADMIN`. We deliberately accept only JWT here: a key should not be
 * able to mint further keys (a compromised key then can't escalate to new
 * rotating keys under different names). The filter still attaches api-key
 * auth to the context — Spring Security rejects requests without the
 * ADMIN role regardless, and JWT remains the intended path.
 */
@RestController
@RequestMapping("/api/admin/api-keys")
@Tag(name = "API Keys Admin")
class ApiKeyAdminController(private val service: ApiKeyAdminService) {

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  @Operation(
    summary = "Mint a new api key. The plaintext key is returned exactly once.",
    security = [SecurityRequirement(name = "bearer-jwt")],
  )
  suspend fun create(@Valid @RequestBody req: ApiKeyCreateRequest): ApiKeyCreatedResponse =
    service.create(req)

  @GetMapping
  @Operation(
    summary = "List api keys (never includes the hash or secret).",
    security = [SecurityRequirement(name = "bearer-jwt")],
  )
  suspend fun list(): List<ApiKeyListItem> = service.list().toList()

  @DeleteMapping("/{id}")
  @Operation(
    summary = "Revoke an api key. Idempotent — returns 204 whether already revoked or not.",
    security = [SecurityRequirement(name = "bearer-jwt")],
  )
  suspend fun revoke(@PathVariable id: UUID): ResponseEntity<Void> {
    service.revoke(id)
    return ResponseEntity.noContent().build()
  }
}
