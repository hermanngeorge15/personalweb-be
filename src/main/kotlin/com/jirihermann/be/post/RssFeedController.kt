package com.jirihermann.be.post

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.nio.charset.StandardCharsets

internal val RSS_MEDIA_TYPE = MediaType("application", "rss+xml", StandardCharsets.UTF_8)

/**
 * Serves the blog feed under the API prefix, which is the only path the site's reverse proxy
 * forwards to this service. Anonymous GET is permitted in SecurityConfig; the response is the
 * same for every reader, so a shared cache may keep it.
 */
@RestController
@Tag(name = "Posts")
class RssFeedController(private val feed: RssFeedService) {
  @GetMapping(RSS_FEED_PATH)
  @Operation(summary = "RSS 2.0 feed of published posts (public)")
  suspend fun rss(): ResponseEntity<ByteArray> =
    ResponseEntity.ok()
      .contentType(RSS_MEDIA_TYPE)
      .header(HttpHeaders.CACHE_CONTROL, "public, max-age=900")
      .body(feed.render())
}
