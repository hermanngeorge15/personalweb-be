package com.jirihermann.be.media

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "media")
data class MediaProperties(
  /** Absolute directory on disk where uploaded files are stored. */
  val baseDir: String = "/app/media",
  /** Maximum upload size in bytes. Default 20 MiB. */
  val maxUploadBytes: Long = 20L * 1024 * 1024,
  /** Allowed MIME type prefixes. */
  val allowedMimePrefixes: List<String> = listOf(
    "image/",
    "video/",
    "application/pdf",
  ),
)
