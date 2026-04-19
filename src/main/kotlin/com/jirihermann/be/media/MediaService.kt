package com.jirihermann.be.media

import org.slf4j.LoggerFactory
import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import java.nio.channels.FileChannel
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import java.nio.file.StandardOpenOption
import java.security.MessageDigest

data class UploadResult(
  val url: String,
  val filename: String,
  val size: Long,
  val contentType: String?,
)

@Service
class MediaService(private val props: MediaProperties) {
  private val logger = LoggerFactory.getLogger(MediaService::class.java)

  init {
    Files.createDirectories(Paths.get(props.baseDir))
  }

  fun store(file: FilePart, folder: String?): Mono<UploadResult> {
    val contentType = file.headers().contentType?.toString()
    if (contentType != null && props.allowedMimePrefixes.none { contentType.startsWith(it) }) {
      return Mono.error(IllegalArgumentException("Content-Type '$contentType' not allowed"))
    }

    val ext = sniffExtension(file.filename(), contentType)
    val safeFolder = folder?.replace(Regex("[^A-Za-z0-9_-]"), "")?.ifBlank { null }
    val tmp = Files.createTempFile(Paths.get(props.baseDir), "upload-", ".tmp")

    return file.transferTo(tmp)
      .then(Mono.fromCallable { finalize(tmp, ext, safeFolder, contentType) })
      .doOnError { err ->
        logger.warn("Upload failed: {}", err.message)
        runCatching { Files.deleteIfExists(tmp) }
      }
  }

  private fun finalize(tmp: Path, ext: String, folder: String?, contentType: String?): UploadResult {
    val size = Files.size(tmp)
    if (size > props.maxUploadBytes) {
      Files.deleteIfExists(tmp)
      throw IllegalArgumentException("Upload exceeds max size (${props.maxUploadBytes} bytes)")
    }
    val hash = sha256Hex(tmp)
    val shortName = "${hash.take(32)}$ext"
    val relPath = if (folder.isNullOrBlank()) shortName else "$folder/$shortName"
    val targetDir = Paths.get(props.baseDir, folder ?: "")
    Files.createDirectories(targetDir)
    val target = targetDir.resolve(shortName)

    if (Files.exists(target)) {
      Files.deleteIfExists(tmp)
    } else {
      Files.move(tmp, target, StandardCopyOption.REPLACE_EXISTING)
    }

    return UploadResult(
      url = "/api/media/files/$relPath",
      filename = relPath,
      size = size,
      contentType = contentType,
    )
  }

  fun resolve(relativePath: String): Path? {
    // Reject path traversal.
    if (relativePath.contains("..") || relativePath.startsWith("/")) return null
    val base = Paths.get(props.baseDir).toAbsolutePath().normalize()
    val candidate = base.resolve(relativePath).normalize()
    if (!candidate.startsWith(base)) return null
    return if (Files.isRegularFile(candidate)) candidate else null
  }

  private fun sniffExtension(filename: String?, contentType: String?): String {
    val fromName = filename?.substringAfterLast('.', "")?.lowercase()
    if (!fromName.isNullOrBlank() && fromName.length <= 5 && fromName.all { it.isLetterOrDigit() }) {
      return ".$fromName"
    }
    return when (contentType) {
      "image/png" -> ".png"
      "image/jpeg" -> ".jpg"
      "image/gif" -> ".gif"
      "image/webp" -> ".webp"
      "image/svg+xml" -> ".svg"
      "application/pdf" -> ".pdf"
      else -> ".bin"
    }
  }

  private fun sha256Hex(path: Path): String {
    val md = MessageDigest.getInstance("SHA-256")
    FileChannel.open(path, StandardOpenOption.READ).use { ch ->
      val buf = java.nio.ByteBuffer.allocate(8192)
      while (ch.read(buf) > 0) {
        buf.flip()
        md.update(buf)
        buf.clear()
      }
    }
    return md.digest().joinToString("") { "%02x".format(it) }
  }
}
