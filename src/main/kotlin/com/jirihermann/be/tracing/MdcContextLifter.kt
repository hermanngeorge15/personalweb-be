package com.jirihermann.be.tracing

import jakarta.annotation.PostConstruct
import jakarta.annotation.PreDestroy
import org.slf4j.MDC
import reactor.core.publisher.Hooks
import reactor.core.publisher.Operators
import reactor.core.CoreSubscriber
import org.springframework.stereotype.Component

/**
 * Automatically lifts MDC context into Reactor Context for all reactive operations.
 * This ensures that tracing information is available throughout the reactive chain.
 */
@Component
class MdcContextLifter {
    
    companion object {
        const val MDC_CONTEXT_KEY = "MDC_CONTEXT"
        private const val HOOK_KEY = "mdc-context-hook"
    }
    
    @PostConstruct
    fun contextOperatorHook() {
        Hooks.onEachOperator(
            HOOK_KEY,
            Operators.lift { _, subscriber: CoreSubscriber<in Any?> ->
                @Suppress("UNCHECKED_CAST")
                MdcContextSubscriber(subscriber as CoreSubscriber<Any?>)
            }
        )
    }
    
    @PreDestroy
    fun cleanupHook() {
        Hooks.resetOnEachOperator(HOOK_KEY)
    }
    
    /**
     * Custom subscriber that propagates MDC context
     */
    private class MdcContextSubscriber<T>(
        private val delegate: CoreSubscriber<T>
    ) : CoreSubscriber<T> {
        
        override fun onSubscribe(s: org.reactivestreams.Subscription) {
            delegate.onSubscribe(s)
        }
        
        override fun onNext(t: T) {
            withMdc {
                delegate.onNext(t)
            }
        }
        
        override fun onError(throwable: Throwable) {
            withMdc {
                delegate.onError(throwable)
            }
        }
        
        override fun onComplete() {
            withMdc {
                delegate.onComplete()
            }
        }
        
        override fun currentContext(): reactor.util.context.Context {
            return delegate.currentContext()
        }
        
        private fun withMdc(block: () -> Unit) {
            val previousMdc = MDC.getCopyOfContextMap()
            try {
                // Restore MDC from context if available
                val context = delegate.currentContext()
                if (context.hasKey(TracingContext.CONTEXT_KEY)) {
                    val tracingContext = context.get<TracingContext>(TracingContext.CONTEXT_KEY)
                    MDC.put("traceId", tracingContext.traceId)
                    MDC.put("spanId", tracingContext.spanId)
                }
                block()
            } finally {
                // Restore previous MDC state
                MDC.clear()
                previousMdc?.let { MDC.setContextMap(it) }
            }
        }
    }
}

