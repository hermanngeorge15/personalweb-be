package com.jirihermann.be.auth

import kotlinx.coroutines.reactor.awaitSingleOrNull
import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import org.springframework.r2dbc.core.DatabaseClient
import org.springframework.stereotype.Repository
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
      .map { row, _ ->
        @Suppress("UNCHECKED_CAST")
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
      }
      .one()
      .awaitSingleOrNull()

  suspend fun markUsed(id: UUID) {
    db.sql("UPDATE api_keys SET last_used_at = now() WHERE id = :id")
      .bind("id", id)
      .fetch()
      .rowsUpdated()
      .awaitSingleOrNull()
  }
}
