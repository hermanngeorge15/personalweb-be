package com.jirihermann.be.recaptcha

import com.jirihermann.be.config.RecaptchaProperties
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.awaitBody
import software.amazon.awssdk.core.internal.waiters.ResponseOrException.response
import kotlin.jvm.java
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

            if (properties.secretKey.isBlank()) {
                logger.error("reCAPTCHA secret key is not configured")
                return RecaptchaVerifyResponse(success = false, errorCodes = listOf("missing-secret-key"))
            }

            return try {
                val response = webClient.post()
                    .uri(properties.verifyUrl)
                    .bodyValue(mapOf(
                        "secret" to properties.secretKey,
                        "response" to token,
                        "remoteip" to (remoteIp ?: "8.8.8.8")
                    ))
                    .retrieve()
                    .awaitBody<RecaptchaVerifyResponse>()

                logger.info("reCAPTCHA verification result: success=${response.success}, score=${response.score}, action=${response.action}")
                response
            } catch (e: Exception) {
                logger.error("Failed to verify reCAPTCHA token", e)
                RecaptchaVerifyResponse(success = false, errorCodes = listOf("verification-failed"))
            }
        }

        fun isScoreAcceptable(score: Double?): Boolean {
            return score != null && score >= properties.minimumScore
        }
    }