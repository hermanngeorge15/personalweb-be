package com.jirihermann.be.tracing

import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient
import org.springframework.test.web.reactive.server.WebTestClient
import java.util.UUID

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient
class TracingTest {
    
    @Autowired
    private lateinit var webTestClient: WebTestClient
    
    private val logger = LoggerFactory.getLogger(TracingTest::class.java)
    
    @Test
    fun `should propagate trace ID from request to response`() {
        val traceId = UUID.randomUUID().toString()
        
        webTestClient.get()
            .uri("/api/posts")
            .header("X-Trace-Id", traceId)
            .exchange()
            .expectStatus().isOk
            .expectHeader().valueEquals("X-Trace-Id", traceId)
            .expectHeader().exists("X-Span-Id")
    }
    
    @Test
    fun `should generate trace ID if not provided`() {
        webTestClient.get()
            .uri("/api/posts")
            .exchange()
            .expectStatus().isOk
            .expectHeader().exists("X-Trace-Id")
            .expectHeader().exists("X-Span-Id")
    }
    
    @Test
    fun `should accept span ID from frontend`() {
        val traceId = UUID.randomUUID().toString()
        val spanId = "frontend-span-123"
        
        webTestClient.get()
            .uri("/api/posts")
            .header("X-Trace-Id", traceId)
            .header("X-Span-Id", spanId)
            .exchange()
            .expectStatus().isOk
            .expectHeader().valueEquals("X-Trace-Id", traceId)
            .expectHeader().valueEquals("X-Span-Id", spanId)
    }
    
    @Test
    fun `withTracing should set MDC values`() = runBlocking {
        val context = TracingContext(
            traceId = "test-trace-123",
            spanId = "test-span-456"
        )
        
        withContext(TracingContextElement(context) + kotlinx.coroutines.slf4j.MDCContext()) {
            withTracing {
                val traceId = MDC.get("traceId")
                val spanId = MDC.get("spanId")
                
                assertEquals("test-trace-123", traceId)
                assertEquals("test-span-456", spanId)
            }
        }
    }
    
    @Test
    fun `withChildSpan should create new span with same trace ID`() = runBlocking {
        val parentContext = TracingContext(
            traceId = "parent-trace",
            spanId = "parent-span"
        )
        
        withContext(TracingContextElement(parentContext) + kotlinx.coroutines.slf4j.MDCContext()) {
            withTracing {
                val parentTraceId = getTraceId()
                val parentSpanId = getSpanId()
                
                assertEquals("parent-trace", parentTraceId)
                assertEquals("parent-span", parentSpanId)
                
                // Create child span
                withChildSpan("test-operation") {
                    val childTraceId = getTraceId()
                    val childSpanId = getSpanId()
                    
                    // Same trace ID
                    assertEquals(parentTraceId, childTraceId)
                    // Different span ID
                    assertNotEquals(parentSpanId, childSpanId)
                    
                    // Check MDC
                    assertEquals("parent-trace", MDC.get("traceId"))
                    assertNotNull(MDC.get("spanId"))
                    assertEquals("test-operation", MDC.get("operation"))
                }
            }
        }
    }
    
    @Test
    fun `currentTracingContext should return context from coroutine`() = runBlocking {
        val expected = TracingContext(
            traceId = "test-trace",
            spanId = "test-span"
        )
        
        withContext(TracingContextElement(expected)) {
            val actual = currentTracingContext()
            
            assertNotNull(actual)
            assertEquals(expected.traceId, actual?.traceId)
            assertEquals(expected.spanId, actual?.spanId)
        }
    }
}

