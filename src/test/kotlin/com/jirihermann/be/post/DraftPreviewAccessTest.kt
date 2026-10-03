package com.jirihermann.be.post

import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.security.authentication.AnonymousAuthenticationToken
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority

class DraftPreviewAccessTest {
  private fun signedIn(vararg roles: String) =
    UsernamePasswordAuthenticationToken("u", null, roles.map { SimpleGrantedAuthority(it) })

  @Test
  fun `should not preview drafts when nobody is signed in`() {
    assertFalse(canPreviewDrafts(null))
  }

  @Test
  fun `should not preview drafts when the reader is anonymous`() {
    val anonymous = AnonymousAuthenticationToken("key", "anonymous", listOf(SimpleGrantedAuthority("ROLE_ANONYMOUS")))
    assertFalse(canPreviewDrafts(anonymous))
  }

  @Test
  fun `should not preview drafts when the signed-in user has no admin or publisher role`() {
    assertFalse(canPreviewDrafts(signedIn("ROLE_USER")))
  }

  @Test
  fun `should preview drafts when the reader is an admin or a publisher`() {
    assertTrue(canPreviewDrafts(signedIn("ROLE_ADMIN")))
    assertTrue(canPreviewDrafts(signedIn("ROLE_PUBLISHER")))
  }
}
