package com.jirihermann.be.meta

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

data class VersionInfo(
  val version: String,
  val gitCommit: String,
  val buildTime: String,
  val environment: String,
  val uptime: Long
)

@RestController
@RequestMapping("/api")
@Tag(name = "System")
class VersionController(
  @Value("\${spring.application.name}") private val appName: String,
  @Value("\${GIT_COMMIT:unknown}") private val gitCommit: String,
  @Value("\${BUILD_TIME:unknown}") private val buildTime: String,
  @Value("\${ENVIRONMENT:production}") private val environment: String
) {

  private val startTime = Instant.now()

  @GetMapping("/version")
  @Operation(summary = "Get application version and build info (public)")
  fun getVersion(): VersionInfo {
    val now = Instant.now()
    val uptime = java.time.Duration.between(startTime, now).seconds

    return VersionInfo(
      version = "0.0.1-SNAPSHOT",
      gitCommit = gitCommit,
      buildTime = buildTime,
      environment = environment,
      uptime = uptime
    )
  }
}

