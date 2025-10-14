package com.jirihermann.be.recaptcha

import com.jirihermann.be.config.RecaptchaProperties
import kotlinx.coroutines.reactor.awaitSingle
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.awaitBody
import reactor.core.publisher.Mono

@Service
class RecaptchaServiceImpl(
    private val properties: RecaptchaProperties,
    private val webClient: WebClient
) {
    private val logger = LoggerFactory.getLogger(RecaptchaServiceImpl::class.java)

    suspend fun verifyToken(token: String, remoteIp: String? = null): RecaptchaVerifyResponse {
        if (!properties.enabled) {
            logger.warn("reCAPTCHA verification is disabled")
            return RecaptchaVerifyResponse(success = true, score = 1.0)
        }

        if (properties.secret.isBlank()) {
            logger.error("reCAPTCHA secret key is not configured")
            return RecaptchaVerifyResponse(success = false, errorCodes = listOf("missing-secret-key"))
        }

        return try {
            // Build form-encoded body as per v3 API docs
            val body = buildString {
                append("secret=${properties.secret}")
                append("&response=$token")
                if (!remoteIp.isNullOrBlank()) {
                    append("&remoteip=$remoteIp")
                }
            }

            logger.info("Verifying reCAPTCHA token with standard v3 API")
            logger.debug("Request URL: ${properties.verifyUrl}")

            val response = webClient.post()
                .uri(properties.verifyUrl)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .bodyValue(body)
                .retrieve()
                .bodyToMono(RecaptchaVerifyResponse::class.java)
                .awaitSingle()

            if (!response.success) {
                logger.error("reCAPTCHA verification failed: success=${response.success}, score=${response.score}, action=${response.action}, errorCodes=${response.errorCodes}")
            } else {
                logger.info("reCAPTCHA verification result: success=${response.success}, score=${response.score}, action=${response.action}, hostname=${response.hostname}")
            }

            response
        } catch (e: Exception) {
            logger.error("Failed to verify reCAPTCHA token", e)
            RecaptchaVerifyResponse(success = false, errorCodes = listOf("verification-failed: ${e.message}"))
        }
    }

    fun isScoreAcceptable(score: Double?): Boolean {
        return score != null && score >= properties.minimumScore
    }

    fun isActionValid(actual: String?, expected: String = properties.expectedAction): Boolean {
        return actual == expected
    }

    fun isHostnameValid(actual: String?): Boolean {
        if (properties.expectedHostname.isBlank()) return true
        return actual == properties.expectedHostname
    }
}