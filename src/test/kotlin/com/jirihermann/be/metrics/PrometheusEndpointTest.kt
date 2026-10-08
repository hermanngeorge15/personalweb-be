package com.jirihermann.be.metrics

import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.web.reactive.server.WebTestClient

/**
 * Boots the whole application and reads the Prometheus scrape endpoint the dashboard uses.
 *
 * Nothing here touches the database: Flyway is off, the R2DBC pool connects lazily and the gauge
 * refresher is disabled, so the test needs no Docker. Spring Boot turns metrics export off in
 * tests unless they opt in, hence @AutoConfigureObservability.
 */
@AutoConfigureObservability(tracing = false)
@SpringBootTest(
  webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
  properties = [
    "spring.flyway.enabled=false",
    "aws.ses.enabled=false",
    "recaptcha.enabled=false",
    "kotlin-playground.enabled=false",
    "business-metrics.refresh.enabled=false",
    "management.tracing.enabled=false",
    "media.base-dir=build/test-media",
  ],
)
class PrometheusEndpointTest {
  @Autowired
  private lateinit var client: WebTestClient

  @Test
  fun `should expose the business counters on the prometheus endpoint without signing in`() {
    val body = client.get().uri("/actuator/prometheus")
      .exchange()
      .expectStatus().isOk
      .expectBody(String::class.java)
      .returnResult()
      .responseBody
      .orEmpty()

    assertTrue(
      body.contains("""blog_email_sent_total{application="be",environment="dev",result="sent",type="contact_notification"}"""),
      "blog_email_sent_total missing",
    )
    assertTrue(
      body.contains("""blog_contact_submissions_total{application="be",environment="dev",outcome="accepted"}"""),
      "blog_contact_submissions_total missing",
    )
    assertTrue(body.contains("blog_recaptcha_score_bucket"), "blog_recaptcha_score missing")
    assertTrue(body.contains("blog_content_items{"), "blog_content_items missing")
    assertTrue(body.contains("blog_contact_messages_open{"), "blog_contact_messages_open missing")
  }
}
