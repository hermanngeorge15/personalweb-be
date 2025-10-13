package com.jirihermann.be.tracing

import java.util.UUID
import kotlin.coroutines.CoroutineContext

/**
 * Holds tracing information (trace ID and span ID)
 */
data class TracingContext(
    val traceId: String,
    val spanId: String
) {
    companion object {
        const val TRACE_ID_HEADER = "X-Trace-Id"
        const val SPAN_ID_HEADER = "X-Span-Id"
        
        // Reactor context key
        const val CONTEXT_KEY = "TRACING_CONTEXT"
        
        fun generate(): TracingContext {
            return TracingContext(
                traceId = UUID.randomUUID().toString(),
                spanId = generateSpanId()
            )
        }
        
        fun withTraceId(traceId: String): TracingContext {
            return TracingContext(
                traceId = traceId,
                spanId = generateSpanId()
            )
        }
        
        fun generateSpanId(): String {
            return UUID.randomUUID().toString().substring(0, 16)
        }
    }
}

/**
 * Coroutine context element to hold tracing information
 */
class TracingContextElement(
    val tracingContext: TracingContext
) : CoroutineContext.Element {
    companion object Key : CoroutineContext.Key<TracingContextElement>
    
    override val key: CoroutineContext.Key<*> = Key
}

