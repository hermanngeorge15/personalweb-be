package com.jirihermann.be.config

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.slf4j.MDCContext
import kotlinx.coroutines.withContext
import org.slf4j.MDC
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import reactor.core.scheduler.Schedulers
import kotlinx.coroutines.reactor.ReactorContext
import kotlin.coroutines.CoroutineContext

/**
 * Configuration for distributed tracing support
 */
@Configuration
class TracingConfig {
    
    /**
     * Custom coroutine context that includes MDC propagation
     */
    @Bean
    fun tracingCoroutineContext(): CoroutineContext {
        return MDCContext()
    }
}

/**
 * Helper to run suspending code with MDC context from Reactor Context
 */
suspend fun <T> withReactorMDC(block: suspend () -> T): T {
    val reactorContext = kotlin.coroutines.coroutineContext[ReactorContext]?.context
    
    if (reactorContext != null && reactorContext.hasKey("TRACING_CONTEXT")) {
        val tracingContext = reactorContext.get<com.jirihermann.be.tracing.TracingContext>("TRACING_CONTEXT")
        val mdcMap = mapOf(
            "traceId" to tracingContext.traceId,
            "spanId" to tracingContext.spanId
        )
        return withContext(MDCContext(mdcMap)) {
            block()
        }
    }
    
    return block()
}

