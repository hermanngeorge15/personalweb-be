package com.jirihermann.be.recaptcha

import com.jirihermann.be.config.RecaptchaProperties
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.web.reactive.function.client.WebClient

class RecaptchaServiceTest {

    @Test
    fun `verifyToken returns success when reCAPTCHA is disabled`() = runTest {
        val properties = RecaptchaProperties(enabled = false)
        val webClient = mockk<WebClient>()
        val service = RecaptchaServiceImpl(properties, webClient)

        val result = service.verifyToken("dummy-token")

        assertTrue(result.success)
        assertEquals(1.0, result.score)
    }

    @Test
    fun `verifyToken returns failure when secret key is missing`() = runTest {
        val properties = RecaptchaProperties(
            enabled = true,
            secret = ""
        )
        val webClient = mockk<WebClient>()
        val service = RecaptchaServiceImpl(properties, webClient)

        val result = service.verifyToken("dummy-token")

        assertFalse(result.success)
        assertTrue(result.errorCodes?.contains("missing-secret-key") == true)
    }

    @Test
    fun `isScoreAcceptable returns true for score above threshold`() {
        val properties = RecaptchaProperties(minimumScore = 0.5)
        val webClient = mockk<WebClient>()
        val service = RecaptchaServiceImpl(properties, webClient)

        assertTrue(service.isScoreAcceptable(0.7))
        assertTrue(service.isScoreAcceptable(0.5))
        assertFalse(service.isScoreAcceptable(0.3))
        assertFalse(service.isScoreAcceptable(null))
    }
}