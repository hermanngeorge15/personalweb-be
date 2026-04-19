package com.jirihermann.be.media

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.core.io.FileSystemResource
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.http.codec.multipart.FilePart
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestPart
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.reactive.function.server.ServerResponse
import org.springframework.web.server.ResponseStatusException
import reactor.core.publisher.Mono
import java.net.URLConnection
import java.nio.file.Files

@RestController
@RequestMapping("/api/media")
@Tag(name = "Media")
class MediaController(private val service: MediaService) {

  @PostMapping(consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
  @Operation(summary = "Upload a media file (admin)", security = [SecurityRequirement(name = "bearer-jwt")])
  fun upload(
    @RequestPart("file") file: FilePart,
    @RequestParam("folder", required = false) folder: String?,
  ): Mono<UploadResult> =
    service.store(file, folder)
      .onErrorMap(IllegalArgumentException::class.java) { ex ->
        ResponseStatusException(HttpStatus.BAD_REQUEST, ex.message)
      }

  @GetMapping("/files/{*path}")
  @Operation(summary = "Fetch a stored media file (public)")
  fun serve(@PathVariable path: String): ResponseEntity<FileSystemResource> {
    val relative = path.trimStart('/')
    val resolved = service.resolve(relative)
      ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    val contentType = Files.probeContentType(resolved) ?: URLConnection.guessContentTypeFromName(resolved.fileName.toString())
    val resource = FileSystemResource(resolved)
    return ResponseEntity.ok()
      .header("Cache-Control", "public, max-age=31536000, immutable")
      .also { if (contentType != null) it.contentType(MediaType.parseMediaType(contentType)) }
      .body(resource)
  }
}
