package com.jirihermann.be.tracing

import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono
import reactor.util.context.Context

/**
 * WebFilter that extracts tracing information from request headers,
 * generates new IDs if not present, and propagates them through the reactive context.
 * 
 * Order -100 ensures this runs early in the filter chain.
 */
@Component
@Order(-100)
class TracingWebFilter : WebFilter {
    
    private val logger = LoggerFactory.getLogger(TracingWebFilter::class.java)
    
    override fun filter(exchange: ServerWebExchange, chain: WebFilterChain): Mono<Void> {
        val request = exchange.request
        
        // Extract or generate trace ID
        val traceId = request.headers.getFirst(TracingContext.TRACE_ID_HEADER)
            ?: TracingContext.generate().traceId
        
        // Extract or generate span ID
        val spanId = request.headers.getFirst(TracingContext.SPAN_ID_HEADER)
            ?: TracingContext.generateSpanId()
        
        val tracingContext = TracingContext(traceId, spanId)
        
        logger.debug("Tracing context: traceId={}, spanId={}, path={}", 
            traceId, spanId, request.path.value())
        
        // Add tracing headers to response
        exchange.response.headers.add(TracingContext.TRACE_ID_HEADER, traceId)
        exchange.response.headers.add(TracingContext.SPAN_ID_HEADER, spanId)
        
        // Continue the chain with tracing context in Reactor Context
        return chain.filter(exchange)
            .contextWrite { ctx ->
                ctx.put(TracingContext.CONTEXT_KEY, tracingContext)
            }
            .doOnEach { signal ->
                // Populate MDC for each signal (onNext, onError, onComplete)
                if (!signal.isOnNext && !signal.isOnError && !signal.isOnComplete) {
                    return@doOnEach
                }
                
                val context = signal.contextView
                if (context.hasKey(TracingContext.CONTEXT_KEY)) {
                    val ctx = context.get<TracingContext>(TracingContext.CONTEXT_KEY)
                    MDC.put("traceId", ctx.traceId)
                    MDC.put("spanId", ctx.spanId)
                } else {
                    MDC.remove("traceId")
                    MDC.remove("spanId")
                }
            }
            .doFinally {
                // Clean up MDC when request completes
                MDC.remove("traceId")
                MDC.remove("spanId")
            }
    }
    
    private companion object {
        private fun generateSpanId(): String = TracingContext.generate().spanId
    }
}




