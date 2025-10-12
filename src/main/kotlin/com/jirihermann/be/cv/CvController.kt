package com.jirihermann.be.cv

import org.springframework.http.CacheControl
import org.springframework.http.ContentDisposition
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.concurrent.TimeUnit

@RestController
class CvController(
  private val assembler: CvAssembler,
  private val renderer: PdfRenderer
) {

  @GetMapping("/cv/{slug}.{lang}.pdf")
  suspend fun getCv(@PathVariable slug: String, @PathVariable lang: String): ResponseEntity<ByteArray> {
    val labels = CvLabels.forLang(lang)
    val cv = assembler.assemble(slug, lang)
    val pdf = renderer.renderCv(cv, labels)

    val eTag = computeETag(pdf)

    val headers = HttpHeaders().apply {
      contentType = MediaType.APPLICATION_PDF
      cacheControl = CacheControl.maxAge(3600, TimeUnit.SECONDS).cachePublic().headerValue
      set(HttpHeaders.ETAG, eTag)
      contentDisposition = ContentDisposition.inline()
        .filename("CV-${cv.fullName}-${lang}.pdf", StandardCharsets.UTF_8)
        .build()
    }

    return ResponseEntity.ok().headers(headers).body(pdf)
  }

  private fun computeETag(bytes: ByteArray): String {
    val md = MessageDigest.getInstance("MD5")
    val hash = md.digest(bytes)
    val hex = hash.joinToString("") { b -> "%02x".format(b) }
    return "\"$hex\"" // quotes required per RFC
  }
}


