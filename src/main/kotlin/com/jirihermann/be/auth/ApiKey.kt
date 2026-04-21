package com.jirihermann.be.auth

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.reactive.asFlow
import kotlinx.coroutines.reactor.awaitSingleOrNull
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import org.springframework.r2dbc.core.DatabaseClient
import org.springframework.stereotype.Repository
import java.security.MessageDigest
import java.time.OffsetDateTime
import java.util.UUID

@Table("api_keys")
data class ApiKeyEntity(
  @Id val id: UUID? = null,
  val public_id: String,
  val key_hash: String,
  val name: String,
  val roles: Array<String>,
  val created_at: OffsetDateTime? = null,
  val last_used_at: OffsetDateTime? = null,
  val revoked_at: OffsetDateTime? = null,
)

/**
 * SHA-256 hex digest. Shared between the filter (verifies incoming secrets)
 * and the admin service (hashes newly-minted secrets for storage).
 */
internal fun sha256Hex(input: String): String {
  val md = MessageDigest.getInstance("SHA-256")
  val bytes = md.digest(input.toByteArray(Charsets.UTF_8))
  return bytes.joinToString("") { "%02x".format(it) }
}

private fun mapRow(row: io.r2dbc.spi.Row): ApiKeyEntity =
  ApiKeyEntity(
    id = row.get("id", UUID::class.java),
    public_id = row.get("public_id", String::class.java)!!,
    key_hash = row.get("key_hash", String::class.java)!!,
    name = row.get("name", String::class.java)!!,
    roles = (row.get("roles", Array<String>::class.java) ?: emptyArray()),
    created_at = row.get("created_at", OffsetDateTime::class.java),
    last_used_at = row.get("last_used_at", OffsetDateTime::class.java),
    revoked_at = row.get("revoked_at", OffsetDateTime::class.java),
  )

@Repository
class ApiKeyRepo(private val db: DatabaseClient) {

  suspend fun findActiveByPublicId(publicId: String): ApiKeyEntity? =
    db.sql(
      """
      SELECT id, public_id, key_hash, name, roles, created_at, last_used_at, revoked_at
      FROM api_keys
      WHERE public_id = :public_id AND revoked_at IS NULL
      """.trimIndent()
    )
      .bind("public_id", publicId)
      .map { row, _ -> mapRow(row) }
      .one()
      .awaitSingleOrNull()

  suspend fun markUsed(id: UUID) {
    db.sql("UPDATE api_keys SET last_used_at = now() WHERE id = :id")
      .bind("id", id)
      .fetch()
      .rowsUpdated()
      .awaitSingleOrNull()
  }

  /**
   * Insert a new api key row. Caller is responsible for generating
   * `publicId` / `keyHash` and for surfacing the plaintext secret to the
   * client exactly once — it is never stored.
   */
  suspend fun create(publicId: String, keyHash: String, name: String, roles: Array<String>): ApiKeyEntity =
    db.sql(
      """
      INSERT INTO api_keys (public_id, key_hash, name, roles)
      VALUES (:public_id, :key_hash, :name, :roles)
      RETURNING id, public_id, key_hash, name, roles, created_at, last_used_at, revoked_at
      """.trimIndent()
    )
      .bind("public_id", publicId)
      .bind("key_hash", keyHash)
      .bind("name", name)
      .bind("roles", roles)
      .map { row, _ -> mapRow(row) }
      .one()
      .awaitSingleOrNull()!!

  fun listAll(): Flow<ApiKeyEntity> =
    db.sql(
      """
      SELECT id, public_id, key_hash, name, roles, created_at, last_used_at, revoked_at
      FROM api_keys
      ORDER BY created_at DESC
      """.trimIndent()
    )
      .map { row, _ -> mapRow(row) }
      .all()
      .asFlow()

  /** Returns number of rows updated — 0 if id unknown or already revoked. */
  suspend fun revoke(id: UUID): Long =
    db.sql(
      """
      UPDATE api_keys SET revoked_at = now()
      WHERE id = :id AND revoked_at IS NULL
      """.trimIndent()
    )
      .bind("id", id)
      .fetch()
      .rowsUpdated()
      .awaitSingleOrNull() ?: 0L
}
