package com.jirihermann.be.contact

import ch.qos.logback.classic.Logger
import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.core.read.ListAppender
import com.jirihermann.be.config.RecaptchaProperties
import com.jirihermann.be.email.EmailService
import com.jirihermann.be.metrics.BusinessMetrics
import com.jirihermann.be.recaptcha.RecaptchaServiceImpl
import com.jirihermann.be.recaptcha.RecaptchaVerifyResponse
import io.micrometer.core.instrument.simple.SimpleMeterRegistry
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import io.mockk.spyk
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.slf4j.LoggerFactory

class ContactControllerTest {
  private val repo: ContactMessageRepo = mockk()
  private val emailService: EmailService = mockk()
  // A real service (its checks read these properties); only the network call is faked below.
  private val recaptcha = spyk(
    RecaptchaServiceImpl(
      RecaptchaProperties(expectedAction = "contact_form", expectedHostname = "jirihermann.com", minimumScore = 0.5),
      mockk(),
    )
  )
  private val registry = SimpleMeterRegistry()
  private val controller = ContactController(repo, emailService, recaptcha, BusinessMetrics(registry))

  private val body = ContactRequest(
    name = "Ada",
    email = "ada@example.com",
    message = "Hello",
    recaptchaToken = "token",
  )
  private val goodResult = RecaptchaVerifyResponse(success = true, score = 0.9, action = "contact_form", hostname = "jirihermann.com")

  @BeforeEach
  fun setup() {
    coEvery { recaptcha.verifyToken(any(), any()) } returns goodResult
    coEvery { repo.save(any()) } answers { firstArg() }
    coEvery { emailService.sendContactFormNotification(any()) } returns true
  }

  private fun outcomes(): Map<String, Double> =
    registry.find(BusinessMetrics.CONTACT_SUBMISSIONS).counters()
      .filter { it.count() > 0 }
      .associate { it.id.getTag("outcome")!! to it.count() }

  private suspend fun submit(request: ContactRequest = body) = controller.submit(request, "203.0.113.7, 10.0.0.1", null)

  @Test
  fun `should count an accepted submission and record its score`() = runTest {
    submit()

    assertEquals(mapOf("accepted" to 1.0), outcomes())
    assertEquals(1, registry.get(BusinessMetrics.RECAPTCHA_SCORE).summary().count())
    coVerify(exactly = 1) { repo.save(any()) }
  }

  @Test
  fun `should count a honeypot hit without checking the captcha`() = runTest {
    submit(body.copy(website = "http://spam.example"))

    assertEquals(mapOf("honeypot" to 1.0), outcomes())
    coVerify(exactly = 0) { recaptcha.verifyToken(any(), any()) }
    coVerify(exactly = 0) { repo.save(any()) }
  }

  @Test
  fun `should count a missing captcha token`() = runTest {
    assertThrows<IllegalArgumentException> { submit(body.copy(recaptchaToken = " ")) }

    assertEquals(mapOf("captcha_missing" to 1.0), outcomes())
  }

  @Test
  fun `should count a failed captcha verification`() = runTest {
    coEvery { recaptcha.verifyToken(any(), any()) } returns RecaptchaVerifyResponse(success = false)

    assertThrows<IllegalArgumentException> { submit() }

    assertEquals(mapOf("captcha_failed" to 1.0), outcomes())
  }

  @Test
  fun `should count an action mismatch`() = runTest {
    coEvery { recaptcha.verifyToken(any(), any()) } returns goodResult.copy(action = "login")

    assertThrows<IllegalArgumentException> { submit() }

    assertEquals(mapOf("action_mismatch" to 1.0), outcomes())
  }

  @Test
  fun `should count a hostname mismatch`() = runTest {
    coEvery { recaptcha.verifyToken(any(), any()) } returns goodResult.copy(hostname = "evil.example")

    assertThrows<IllegalArgumentException> { submit() }

    assertEquals(mapOf("hostname_mismatch" to 1.0), outcomes())
  }

  @Test
  fun `should count a low score and still record it`() = runTest {
    coEvery { recaptcha.verifyToken(any(), any()) } returns goodResult.copy(score = 0.1)

    assertThrows<IllegalArgumentException> { submit() }

    assertEquals(mapOf("low_score" to 1.0), outcomes())
    assertEquals(0.1, registry.get(BusinessMetrics.RECAPTCHA_SCORE).summary().totalAmount(), 1e-9)
  }

  @Test
  fun `should count an unexpected failure as error and rethrow it`() = runTest {
    coEvery { repo.save(any()) } throws IllegalStateException("database down")

    val thrown = assertThrows<IllegalStateException> { submit() }

    assertEquals("database down", thrown.message)
    assertEquals(mapOf("error" to 1.0), outcomes())
  }

  @Test
  fun `should still accept the submission when the notification email fails`() = runTest {
    coEvery { emailService.sendContactFormNotification(any()) } returns false

    submit()

    assertEquals(mapOf("accepted" to 1.0), outcomes())
  }

  @Test
  fun `should log the submitter's email and IP only as fingerprints`() = runTest {
    val appender = ListAppender<ILoggingEvent>().apply { start() }
    val logger = LoggerFactory.getLogger(ContactController::class.java) as Logger
    logger.addAppender(appender)
    try {
      submit()
      submit(body.copy(website = "http://spam.example"))
      coEvery { recaptcha.verifyToken(any(), any()) } returns goodResult.copy(score = 0.1)
      assertThrows<IllegalArgumentException> { submit() }
    } finally {
      logger.detachAppender(appender)
    }

    val logged = appender.list.joinToString("\n") { it.formattedMessage }
    assertTrue(logged.contains("fp:"), logged)
    assertFalse(logged.contains("ada@example.com"), logged)
    assertFalse(logged.contains("203.0.113.7"), logged)
  }
}
