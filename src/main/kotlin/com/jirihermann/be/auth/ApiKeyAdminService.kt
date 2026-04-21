package com.jirihermann.be.auth

import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import org.springframework.stereotype.Service
import java.security.SecureRandom
import java.time.OffsetDateTime
import java.util.Base64
import java.util.UUID

/**
 * Create payload. `roles` is optional; defaults to `["ADMIN"]` server-side
 * if null or empty to match the behavior of the shell-script mint flow.
 */
data class ApiKeyCreateRequest(
  @field:NotBlank
  @field:Size(max = 128)
  val name: String,
  val roles: List<@NotBlank String>? = null,
)

/** Returned exactly once on creation. `key` is the plaintext — never stored. */
data class ApiKeyCreatedResponse(
  val id: UUID,
  val public_id: String,
  val key: String,
  val name: String,
  val roles: List<String>,
  val created_at: OffsetDateTime?,
)

/** List item — never includes `key_hash` or any plaintext. */
data class ApiKeyListItem(
  val id: UUID,
  val public_id: String,
  val name: String,
  val roles: List<String>,
  val created_at: OffsetDateTime?,
  val last_used_at: OffsetDateTime?,
  val revoked_at: OffsetDateTime?,
)

@Service
class ApiKeyAdminService(
  private val repo: ApiKeyRepo,
  private val random: SecureRandom = SecureRandom(),
) {

  suspend fun create(@Valid req: ApiKeyCreateRequest): ApiKeyCreatedResponse {
    val publicId = randomUrlSafeBase64(PUBLIC_ID_BYTES)
    val secret = randomUrlSafeBase64(SECRET_BYTES)
    val hash = sha256Hex(secret)
    val roles = (req.roles?.takeIf { it.isNotEmpty() } ?: listOf("ADMIN"))
      .map { it.uppercase() }

    val entity = repo.create(
      publicId = publicId,
      keyHash = hash,
      name = req.name,
      roles = roles.toTypedArray(),
    )

    return ApiKeyCreatedResponse(
      id = entity.id!!,
      public_id = entity.public_id,
      key = "$publicId.$secret",
      name = entity.name,
      roles = entity.roles.toList(),
      created_at = entity.created_at,
    )
  }

  fun list(): Flow<ApiKeyListItem> =
    repo.listAll().map {
      ApiKeyListItem(
        id = it.id!!,
        public_id = it.public_id,
        name = it.name,
        roles = it.roles.toList(),
        created_at = it.created_at,
        last_used_at = it.last_used_at,
        revoked_at = it.revoked_at,
      )
    }

  /** True if the key was revoked now, false if it didn't exist or was already revoked. */
  suspend fun revoke(id: UUID): Boolean = repo.revoke(id) > 0

  private fun randomUrlSafeBase64(byteLen: Int): String {
    val buf = ByteArray(byteLen)
    random.nextBytes(buf)
    return Base64.getUrlEncoder().withoutPadding().encodeToString(buf)
  }

  companion object {
    private const val PUBLIC_ID_BYTES = 16
    private const val SECRET_BYTES = 32
  }
}
