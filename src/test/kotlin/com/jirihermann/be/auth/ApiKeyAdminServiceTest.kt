package com.jirihermann.be.auth

import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import io.mockk.slot
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.security.SecureRandom
import java.time.OffsetDateTime
import java.util.UUID

class ApiKeyAdminServiceTest {
  private val repo: ApiKeyRepo = mockk()
  private val service = ApiKeyAdminService(repo, SecureRandom())

  @Test
  fun `create generates key, stores only the hash, returns plaintext once`() = runTest {
    val storedId = UUID.randomUUID()
    val publicIdSlot = slot<String>()
    val keyHashSlot = slot<String>()
    val rolesSlot = slot<Array<String>>()

    coEvery {
      repo.create(capture(publicIdSlot), capture(keyHashSlot), "my-laptop", capture(rolesSlot))
    } answers {
      ApiKeyEntity(
        id = storedId,
        public_id = publicIdSlot.captured,
        key_hash = keyHashSlot.captured,
        name = "my-laptop",
        roles = rolesSlot.captured,
        created_at = OffsetDateTime.now(),
      )
    }

    val resp = service.create(ApiKeyCreateRequest(name = "my-laptop"))

    // Plaintext is returned once and has the expected shape.
    assertEquals(storedId, resp.id)
    assertTrue(resp.key.contains('.'), "key must be '<public_id>.<secret>'")
    val (keyPublicId, keySecret) = resp.key.split('.', limit = 2).let { it[0] to it[1] }
    assertEquals(publicIdSlot.captured, keyPublicId)

    // The stored hash matches the plaintext secret hashed via the shared helper.
    assertEquals(sha256Hex(keySecret), keyHashSlot.captured)

    // The stored hash is NEVER the plaintext secret.
    assertNotEquals(keySecret, keyHashSlot.captured)

    // Default role applied when caller omits roles.
    assertTrue(rolesSlot.captured.contentEquals(arrayOf("ADMIN")))
    assertEquals(listOf("ADMIN"), resp.roles)
  }

  @Test
  fun `create uppercases supplied roles`() = runTest {
    val rolesSlot = slot<Array<String>>()
    coEvery { repo.create(any(), any(), any(), capture(rolesSlot)) } answers {
      ApiKeyEntity(
        id = UUID.randomUUID(),
        public_id = "p", key_hash = "h", name = "ops",
        roles = rolesSlot.captured, created_at = OffsetDateTime.now(),
      )
    }

    val resp = service.create(ApiKeyCreateRequest(name = "ops", roles = listOf("admin", "Publisher")))

    assertTrue(rolesSlot.captured.contentEquals(arrayOf("ADMIN", "PUBLISHER")))
    assertEquals(listOf("ADMIN", "PUBLISHER"), resp.roles)
  }

  @Test
  fun `list projects entities to safe list items without key_hash`() = runTest {
    val e = ApiKeyEntity(
      id = UUID.randomUUID(),
      public_id = "pub-1",
      key_hash = "super-secret-hash",
      name = "x",
      roles = arrayOf("ADMIN"),
      created_at = OffsetDateTime.now(),
    )
    coEvery { repo.listAll() } returns flowOf(e)

    val items = service.list().toList()
    assertEquals(1, items.size)
    val item = items[0]
    assertEquals(e.id, item.id)
    assertEquals("pub-1", item.public_id)
    assertNotNull(item.created_at)

    // Reflective sanity check: the DTO must not expose a key_hash field.
    val fieldNames = ApiKeyListItem::class.java.declaredFields.map { it.name }
    assertFalse(fieldNames.contains("key_hash"))
    assertFalse(fieldNames.contains("key"))
  }

  @Test
  fun `revoke returns true when repo updates a row`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.revoke(id) } returns 1L
    assertTrue(service.revoke(id))
    coVerify(exactly = 1) { repo.revoke(id) }
  }

  @Test
  fun `revoke returns false when nothing updated`() = runTest {
    val id = UUID.randomUUID()
    coEvery { repo.revoke(id) } returns 0L
    assertFalse(service.revoke(id))
  }

  @Test
  fun `create with empty roles list falls back to ADMIN default`() = runTest {
    val rolesSlot = slot<Array<String>>()
    coEvery { repo.create(any(), any(), any(), capture(rolesSlot)) } answers {
      ApiKeyEntity(
        id = UUID.randomUUID(),
        public_id = "p", key_hash = "h", name = "n",
        roles = rolesSlot.captured, created_at = OffsetDateTime.now(),
      )
    }
    service.create(ApiKeyCreateRequest(name = "n", roles = emptyList()))
    assertTrue(rolesSlot.captured.contentEquals(arrayOf("ADMIN")))
  }
}
