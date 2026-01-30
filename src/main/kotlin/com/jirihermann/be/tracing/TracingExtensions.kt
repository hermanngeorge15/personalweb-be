package com.jirihermann.be.tracing

import kotlinx.coroutines.reactor.ReactorContext
import kotlinx.coroutines.slf4j.MDCContext
import kotlinx.coroutines.withContext
import org.slf4j.MDC
import reactor.core.publisher.Mono
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.coroutineContext

/**
 * Extension functions to work with tracing context in coroutines
 */

/**
 * Gets the current tracing context from the coroutine context
 */
suspend fun currentTracingContext(): TracingContext? {
    return coroutineContext[TracingContextElement]?.tracingContext
        ?: coroutineContext[ReactorContext]?.context?.get<TracingContext>(TracingContext.CONTEXT_KEY)
}

/**
 * Executes a block with tracing context properly set in MDC and coroutine context
 */
suspend fun <T> withTracing(block: suspend () -> T): T {
    val tracingContext = currentTracingContext()
    
    if (tracingContext == null) {
        return block()
    }
    
    // Prepare MDC context map
    val mdcContextMap = mapOf(
        "traceId" to tracingContext.traceId,
        "spanId" to tracingContext.spanId
    )
    
    // Run with both MDC context and tracing context element
    return withContext(
        MDCContext(mdcContextMap) + TracingContextElement(tracingContext)
    ) {
        block()
    }
}

/**
 * Creates a new Mono with tracing context from current coroutine context
 */
suspend fun <T> Mono<T>.withCurrentTracing(): Mono<T> {
    val tracingContext = currentTracingContext() ?: return this
    
    return this.contextWrite { ctx ->
        ctx.put(TracingContext.CONTEXT_KEY, tracingContext)
    }
}

/**
 * Gets trace ID from current coroutine context
 */
suspend fun getTraceId(): String? {
    return currentTracingContext()?.traceId ?: MDC.get("traceId")
}

/**
 * Gets span ID from current coroutine context
 */
suspend fun getSpanId(): String? {
    return currentTracingContext()?.spanId ?: MDC.get("spanId")
}

/**
 * Creates a child span with a new span ID but same trace ID
 */
suspend fun <T> withChildSpan(operation: String? = null, block: suspend () -> T): T {
    val parentContext = currentTracingContext()
    
    if (parentContext == null) {
        return block()
    }
    
    // Generate new span ID for child span
    val childSpanId = TracingContext.generate().spanId
    val childContext = TracingContext(
        traceId = parentContext.traceId,
        spanId = childSpanId
    )
    
    val mdcContextMap = mutableMapOf(
        "traceId" to childContext.traceId,
        "spanId" to childContext.spanId
    )
    
    if (operation != null) {
        mdcContextMap["operation"] = operation
    }
    
    return withContext(
        MDCContext(mdcContextMap) + TracingContextElement(childContext)
    ) {
        block()
    }
}

/**
 * Extension to easily log with tracing context
 */
suspend fun logWithTrace(message: () -> String): String {
    val traceId = getTraceId() ?: "no-trace"
    val spanId = getSpanId() ?: "no-span"
    return "[trace=$traceId span=$spanId] ${message()}"
}




