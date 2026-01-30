package com.jirihermann.be.tracing

import kotlinx.coroutines.delay
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

/**
 * Example service showing how to use distributed tracing in Spring WebFlux + Kotlin Coroutines
 */
@Service
class TracingUsageExample {
    
    private val logger = LoggerFactory.getLogger(TracingUsageExample::class.java)
    
    /**
     * Basic example: Tracing is automatic in suspend functions
     * The trace ID and span ID are automatically available in MDC for logging
     */
    suspend fun basicExample() {
        logger.info("This log will automatically include traceId and spanId from MDC")
    }
    
    /**
     * Explicit tracing: Use withTracing {} to ensure MDC is set
     * Recommended for service layer methods
     */
    suspend fun explicitTracingExample() = withTracing {
        logger.info("Explicitly wrapped with tracing context")
        
        val traceId = getTraceId()
        logger.info("Current trace ID: {}", traceId)
    }
    
    /**
     * Child spans: Create nested spans for sub-operations
     * Each child gets a new span ID but keeps the same trace ID
     */
    suspend fun childSpanExample() = withTracing {
        logger.info("Parent operation started")
        
        // First sub-operation with its own span
        withChildSpan("database-query") {
            logger.info("Executing database query") // Has different spanId
            delay(10) // Simulate DB call
        }
        
        // Second sub-operation with its own span
        withChildSpan("external-api-call") {
            logger.info("Calling external API") // Has different spanId
            delay(20) // Simulate API call
        }
        
        logger.info("Parent operation completed")
    }
    
    /**
     * Getting trace information programmatically
     */
    suspend fun accessTracingInfo() {
        val context = currentTracingContext()
        if (context != null) {
            logger.info("TraceId: {}, SpanId: {}", context.traceId, context.spanId)
        }
        
        // Or use convenience functions
        logger.info("TraceId: {}", getTraceId())
        logger.info("SpanId: {}", getSpanId())
    }
    
    /**
     * Complex example with error handling and multiple operations
     */
    suspend fun complexExample(userId: String) = withTracing {
        logger.info("Processing request for user: {}", userId)
        
        try {
            // Fetch user data
            val userData = withChildSpan("fetch-user") {
                logger.info("Fetching user data")
                fetchUserData(userId)
            }
            
            // Process data
            val result = withChildSpan("process-data") {
                logger.info("Processing user data")
                processUserData(userData)
            }
            
            // Save result
            withChildSpan("save-result") {
                logger.info("Saving result")
                saveResult(result)
            }
            
            logger.info("Request completed successfully")
            result
            
        } catch (e: Exception) {
            logger.error("Error processing request: {}", e.message, e)
            throw e
        }
    }
    
    // Mock helper methods
    private suspend fun fetchUserData(userId: String): String {
        delay(10)
        return "UserData-$userId"
    }
    
    private suspend fun processUserData(data: String): String {
        delay(20)
        return "Processed-$data"
    }
    
    private suspend fun saveResult(result: String) {
        delay(10)
        logger.info("Saved: {}", result)
    }
}

/**
 * Example controller showing tracing in action
 */
/*
@RestController
@RequestMapping("/api/tracing-example")
class TracingExampleController(
    private val exampleService: TracingUsageExample
) {
    private val logger = LoggerFactory.getLogger(TracingExampleController::class.java)
    
    @GetMapping("/basic")
    suspend fun basic(): Map<String, String?> {
        logger.info("Basic tracing example endpoint called")
        exampleService.basicExample()
        
        return mapOf(
            "traceId" to getTraceId(),
            "spanId" to getSpanId(),
            "message" to "Check logs for tracing information"
        )
    }
    
    @GetMapping("/complex/{userId}")
    suspend fun complex(@PathVariable userId: String): Map<String, Any> {
        logger.info("Complex tracing example endpoint called")
        val result = exampleService.complexExample(userId)
        
        return mapOf(
            "traceId" to getTraceId()!!,
            "spanId" to getSpanId()!!,
            "result" to result
        )
    }
}
*/




