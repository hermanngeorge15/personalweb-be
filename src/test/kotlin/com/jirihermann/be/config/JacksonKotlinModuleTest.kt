package com.jirihermann.be.config

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.exc.MismatchedInputException
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import com.jirihermann.be.project.ProjectService
import com.jirihermann.be.recaptcha.RecaptchaVerifyResponse
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertSame
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.ImportAutoConfiguration
import org.springframework.boot.autoconfigure.http.codec.CodecsAutoConfiguration
import org.springframework.boot.test.autoconfigure.json.JsonTest
import org.springframework.boot.web.codec.CodecCustomizer
import org.springframework.http.codec.DecoderHttpMessageReader
import org.springframework.http.codec.HttpMessageReader
import org.springframework.http.codec.ServerCodecConfigurer
import org.springframework.http.codec.json.Jackson2JsonDecoder
import org.springframework.web.reactive.function.client.ExchangeStrategies

/**
 * Proves that the ObjectMapper Spring Boot builds for this app, and the one WebFlux decodes
 * request bodies with, understand Kotlin: default parameter values apply when a field is
 * missing from the JSON, and a missing non-null field is rejected instead of passed as null.
 */
@JsonTest
@ImportAutoConfiguration(CodecsAutoConfiguration::class)
class JacksonKotlinModuleTest {
  data class Sample(
    val name: String,
    val order: Int = 7,
    val links: String = "{}",
    val note: String? = null,
  )

  @Autowired private lateinit var objectMapper: ObjectMapper
  @Autowired private lateinit var codecCustomizers: List<CodecCustomizer>

  @Test
  fun `should register the Kotlin module on the application ObjectMapper`() {
    assertTrue(KotlinModule::class.java.name in objectMapper.registeredModuleIds) {
      "registered modules: ${objectMapper.registeredModuleIds}"
    }
  }

  @Test
  fun `should decode WebFlux request bodies with the application ObjectMapper`() {
    val configurer = ServerCodecConfigurer.create()
    codecCustomizers.forEach { it.customize(configurer) }

    assertSame(objectMapper, jsonDecoder(configurer.readers).objectMapper)
  }

  @Test
  fun `should round-trip a data class with a default parameter and a non-null field`() {
    val sample = Sample(name = "kotlin", order = 3, links = """{"github":"x"}""", note = "n")

    assertEquals(sample, objectMapper.readValue<Sample>(objectMapper.writeValueAsString(sample)))
  }

  @Test
  fun `should apply default parameter values when the fields are missing`() {
    assertEquals(Sample(name = "kotlin"), objectMapper.readValue<Sample>("""{"name":"kotlin"}"""))
  }

  @Test
  fun `should reject the JSON when a non-null field without a default is missing`() {
    val error = assertThrows<MismatchedInputException> {
      objectMapper.readValue<Sample>("""{"order":1}""")
    }
    assertTrue("JSON property name" in error.originalMessage) { error.originalMessage }
  }

  @Test
  fun `should reject the JSON when a non-null field is explicitly null`() {
    assertThrows<MismatchedInputException> {
      objectMapper.readValue<Sample>("""{"name":null}""")
    }
  }

  @Test
  fun `should apply the project request defaults when the admin omits links and order`() {
    val request = objectMapper.readValue<ProjectService.ProjectUpsertRequest>(
      """{"slug":"s","title":"t","summary":"sum","content_mdx":"body"}""",
    )

    assertEquals("{}", request.links)
    assertEquals(0, request.order)
  }

  @Test
  fun `should read the renamed reCAPTCHA fields through the WebClient default decoder`() {
    // RecaptchaServiceImpl uses WebClient.builder().build(), whose JSON decoder is built by
    // ExchangeStrategies.withDefaults() rather than taken from the Spring context.
    val decoder = jsonDecoder(ExchangeStrategies.withDefaults().messageReaders())
    val json = """
      {"success":true,"score":0.9,"action":"contact","challenge_ts":"2026-10-07T08:00:00Z",
       "hostname":"jirihermann.com","error-codes":["timeout-or-duplicate"]}
    """.trimIndent()

    val response = decoder.objectMapper.readValue<RecaptchaVerifyResponse>(json)

    assertEquals("2026-10-07T08:00:00Z", response.challengeTs)
    assertEquals(listOf("timeout-or-duplicate"), response.errorCodes)
  }

  private fun jsonDecoder(readers: List<HttpMessageReader<*>>): Jackson2JsonDecoder =
    readers.filterIsInstance<DecoderHttpMessageReader<*>>()
      .map { it.decoder }
      .filterIsInstance<Jackson2JsonDecoder>()
      .single()
}
