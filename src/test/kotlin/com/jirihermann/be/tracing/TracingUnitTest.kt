package com.jirihermann.be.tracing

import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import org.junit.Ignore
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.slf4j.MDC
import java.util.UUID

/**
 * Unit tests for tracing functionality - no Spring context or database required
 */
class TracingUnitTest {
//
//    @Test
//    fun `TracingContext should generate valid IDs`() {
//        val context = TracingContext.generate()
//
//        assertNotNull(context.traceId)
//        assertNotNull(context.spanId)
//        assertTrue(context.traceId.isNotEmpty())
//        assertTrue(context.spanId.isNotEmpty())
//    }
//
//    @Test
//    fun `TracingContext withTraceId should use provided trace ID`() {
//        val traceId = "my-custom-trace-id"
//        val context = TracingContext.withTraceId(traceId)
//
//        assertEquals(traceId, context.traceId)
//        assertNotNull(context.spanId)
//    }
//
//    @Test
//    fun `generateSpanId should create 16 character span ID`() {
//        val spanId = TracingContext.generateSpanId()
//
//        assertNotNull(spanId)
//        assertEquals(16, spanId.length)
//    }
//
//    @Test
//    fun `withTracing should set MDC values`() = runBlocking {
//        val context = TracingContext(
//            traceId = "test-trace-123",
//            spanId = "test-span-456"
//        )
//
//        withContext(TracingContextElement(context) + kotlinx.coroutines.slf4j.MDCContext()) {
//            withTracing {
//                val traceId = MDC.get("traceId")
//                val spanId = MDC.get("spanId")
//
//                assertEquals("test-trace-123", traceId)
//                assertEquals("test-span-456", spanId)
//            }
//        }
//    }
//
//    @Test
//    fun `withChildSpan should create new span with same trace ID`() = runBlocking {
//        val parentContext = TracingContext(
//            traceId = "parent-trace",
//            spanId = "parent-span"
//        )
//
//        withContext(TracingContextElement(parentContext) + kotlinx.coroutines.slf4j.MDCContext()) {
//            withTracing {
//                val parentTraceId = getTraceId()
//                val parentSpanId = getSpanId()
//
//                assertEquals("parent-trace", parentTraceId)
//                assertEquals("parent-span", parentSpanId)
//
//                // Create child span
//                withChildSpan("test-operation") {
//                    val childTraceId = getTraceId()
//                    val childSpanId = getSpanId()
//
//                    // Same trace ID
//                    assertEquals(parentTraceId, childTraceId)
//                    // Different span ID
//                    assertNotEquals(parentSpanId, childSpanId)
//
//                    // Check MDC
//                    assertEquals("parent-trace", MDC.get("traceId"))
//                    assertNotNull(MDC.get("spanId"))
//                    assertEquals("test-operation", MDC.get("operation"))
//                }
//            }
//        }
//    }
//
//    @Test
//    fun `currentTracingContext should return context from coroutine`() = runBlocking {
//        val expected = TracingContext(
//            traceId = "test-trace",
//            spanId = "test-span"
//        )
//
//        withContext(TracingContextElement(expected)) {
//            val actual = currentTracingContext()
//
//            assertNotNull(actual)
//            assertEquals(expected.traceId, actual?.traceId)
//            assertEquals(expected.spanId, actual?.spanId)
//        }
//    }
//
//    @Test
//    fun `getTraceId should return trace ID from context`() = runBlocking {
//        val context = TracingContext(
//            traceId = "my-trace-id",
//            spanId = "my-span-id"
//        )
//
//        withContext(TracingContextElement(context) + kotlinx.coroutines.slf4j.MDCContext()) {
//            withTracing {
//                val traceId = getTraceId()
//                assertEquals("my-trace-id", traceId)
//            }
//        }
//    }
//
//    @Test
//    fun `getSpanId should return span ID from context`() = runBlocking {
//        val context = TracingContext(
//            traceId = "my-trace-id",
//            spanId = "my-span-id"
//        )
//
//        withContext(TracingContextElement(context) + kotlinx.coroutines.slf4j.MDCContext()) {
//            withTracing {
//                val spanId = getSpanId()
//                assertEquals("my-span-id", spanId)
//            }
//        }
//    }
//
//    @Test
//    fun `withChildSpan should include operation name in MDC`() = runBlocking {
//        val context = TracingContext(
//            traceId = "test-trace",
//            spanId = "test-span"
//        )
//
//        withContext(TracingContextElement(context) + kotlinx.coroutines.slf4j.MDCContext()) {
//            withTracing {
//                withChildSpan("database-query") {
//                    val operation = MDC.get("operation")
//                    assertEquals("database-query", operation)
//                }
//            }
//        }
//    }
}




