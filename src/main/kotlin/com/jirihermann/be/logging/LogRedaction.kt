package com.jirihermann.be.logging

import java.security.SecureRandom
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Personal data (e-mail addresses, IPs) in logs that are shipped to OpenSearch.
 *
 * [fingerprint] replaces a value with a short keyed hash, so repeated submissions from the same
 * address can still be correlated in the logs without the address being stored. The key is
 * random per process: unlike a plain hash, a fingerprint can't be reversed by hashing every IPv4
 * address or a list of known e-mails, at the cost of fingerprints changing after a restart.
 */
object LogRedaction {
  private val key = ByteArray(32).also { SecureRandom().nextBytes(it) }

  /** `fp:3f9a1c0b2d4e` for a value, `none` for null or blank. */
  fun fingerprint(value: String?): String {
    if (value.isNullOrBlank()) return "none"
    val mac = Mac.getInstance("HmacSHA256").apply { init(SecretKeySpec(key, "HmacSHA256")) }
    val digest = mac.doFinal(value.trim().lowercase().toByteArray(Charsets.UTF_8))
    return "fp:" + digest.take(6).joinToString("") { "%02x".format(it) }
  }
}
