package com.jirihermann.be.logging

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class LogRedactionTest {
  @Test
  fun `should replace a value with a short fingerprint that hides it`() {
    val fp = LogRedaction.fingerprint("ada@example.com")

    assertTrue(Regex("fp:[0-9a-f]{12}").matches(fp), fp)
    assertFalse(fp.contains("ada"))
  }

  @Test
  fun `should give the same value the same fingerprint, ignoring case and spaces`() {
    assertEquals(LogRedaction.fingerprint("Ada@Example.com "), LogRedaction.fingerprint("ada@example.com"))
    assertNotEquals(LogRedaction.fingerprint("ada@example.com"), LogRedaction.fingerprint("bob@example.com"))
  }

  @Test
  fun `should say none for a missing value`() {
    assertEquals("none", LogRedaction.fingerprint(null))
    assertEquals("none", LogRedaction.fingerprint("  "))
  }
}
