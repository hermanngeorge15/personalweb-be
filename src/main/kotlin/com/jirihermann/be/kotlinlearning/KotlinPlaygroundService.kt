package com.jirihermann.be.kotlinlearning

import com.jirihermann.be.config.KotlinPlaygroundProperties
import kotlinx.coroutines.reactor.awaitSingle
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import java.time.Duration

@Service
class KotlinPlaygroundService(
    private val properties: KotlinPlaygroundProperties,
    private val webClient: WebClient
) {
    private val logger = LoggerFactory.getLogger(KotlinPlaygroundService::class.java)

    suspend fun executeCode(code: String): ExecuteCodeResponse {
        if (!properties.enabled) {
            logger.warn("Kotlin Playground code execution is disabled")
            return ExecuteCodeResponse(
                output = null,
                errors = listOf("Code execution is disabled"),
                success = false
            )
        }

        return try {
            logger.info("Executing Kotlin code via Playground API")
            logger.debug("Code length: ${code.length} characters")

            val request = KotlinPlaygroundRequest(
                args = "",
                files = listOf(
                    KotlinPlaygroundFile(
                        name = "File.kt",
                        text = code,
                        publicId = ""
                    )
                ),
                confType = "java"
            )

            val response = webClient.post()
                .uri(properties.compilerUrl)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(KotlinPlaygroundResponse::class.java)
                .timeout(Duration.ofMillis(properties.timeout.toLong()))
                .awaitSingle()

            logger.info("Kotlin Playground response received")

            val errors = response.errors?.let { parseErrors(it) } ?: emptyList()
            val hasErrors = errors.isNotEmpty() || response.exception != null

            ExecuteCodeResponse(
                output = response.text?.trimEnd(),
                errors = if (hasErrors) {
                    errors + listOfNotNull(response.exception?.let { "Exception: $it" })
                } else null,
                success = !hasErrors
            )
        } catch (e: Exception) {
            logger.error("Failed to execute Kotlin code", e)
            ExecuteCodeResponse(
                output = null,
                errors = listOf("Execution failed: ${e.message}"),
                success = false
            )
        }
    }

    private fun parseErrors(errorsMap: Map<String, List<KotlinPlaygroundError>>): List<String> {
        return errorsMap.values.flatten().map { error ->
            buildString {
                append(error.severity ?: "ERROR")
                append(": ")
                append(error.message)
                if (error.interval != null) {
                    append(" (line ${error.interval.start?.line ?: "?"})")
                }
            }
        }
    }
}

// Request DTOs for Kotlin Playground API
data class KotlinPlaygroundRequest(
    val args: String = "",
    val files: List<KotlinPlaygroundFile>,
    val confType: String = "java"
)

data class KotlinPlaygroundFile(
    val name: String,
    val text: String,
    val publicId: String = ""
)

// Response DTOs from Kotlin Playground API
data class KotlinPlaygroundResponse(
    val text: String? = null,
    val exception: String? = null,
    val errors: Map<String, List<KotlinPlaygroundError>>? = null
)

data class KotlinPlaygroundError(
    val message: String,
    val severity: String? = null,
    val interval: KotlinPlaygroundInterval? = null,
    val className: String? = null
)

data class KotlinPlaygroundInterval(
    val start: KotlinPlaygroundPosition? = null,
    val end: KotlinPlaygroundPosition? = null
)

data class KotlinPlaygroundPosition(
    val line: Int? = null,
    val ch: Int? = null
)

// Public DTOs for the API
data class ExecuteCodeRequest(
    val code: String
)

data class ExecuteCodeResponse(
    val output: String?,
    val errors: List<String>?,
    val success: Boolean
)
