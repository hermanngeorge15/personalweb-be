# Distributed Tracing for Spring WebFlux + Kotlin Coroutines

This package provides distributed tracing support for Spring WebFlux applications using Kotlin Coroutines.

## Components

### 1. TracingContext
Data class that holds `traceId` and `spanId`. Used as both a Reactor Context value and a Coroutine Context element.

### 2. TracingWebFilter
`@Component` WebFilter that:
- Extracts `X-Trace-Id` and `X-Span-Id` from incoming request headers
- Generates new IDs if not present
- Adds them to response headers
- Propagates them through Reactor Context
- Manages MDC for logging

### 3. TracingExtensions
Helper functions for working with tracing in coroutines:
- `currentTracingContext()`: Get current tracing context
- `withTracing {}`: Execute block with tracing in MDC
- `withChildSpan {}`: Create child span for nested operations
- `getTraceId()`, `getSpanId()`: Convenience accessors

### 4. MdcContextLifter
Automatically lifts MDC values into Reactor Context using Reactor Hooks.

### 5. TracingConfig
Spring configuration that enables tracing features.

## Usage

### In Controllers (Suspend Functions)

```kotlin
@RestController
@RequestMapping("/api/posts")
class PostController(private val service: PostService) {
    
    private val logger = LoggerFactory.getLogger(PostController::class.java)
    
    @GetMapping("/{id}")
    suspend fun getPost(@PathVariable id: UUID): PostDto {
        // Tracing is automatically available in MDC
        logger.info("Fetching post: {}", id)
        
        // Get trace ID if needed
        val traceId = getTraceId()
        
        return service.getPost(id)
    }
}
```

### In Services (With Explicit Tracing)

```kotlin
@Service
class PostService(private val repo: PostRepo) {
    
    private val logger = LoggerFactory.getLogger(PostService::class.java)
    
    suspend fun getPost(id: UUID): PostDto = withTracing {
        // Tracing context is available in MDC here
        logger.info("Service layer: fetching post {}", id)
        
        val post = repo.findById(id)
        
        // Create child span for a sub-operation
        val enrichedPost = withChildSpan("enrich-post") {
            logger.info("Enriching post data")
            enrichPost(post)
        }
        
        enrichedPost
    }
    
    private suspend fun enrichPost(post: PostEntity): PostDto {
        // This will have a different spanId but same traceId
        logger.info("Enriching...")
        // ... enrichment logic
    }
}
```

### In Reactive Flows

```kotlin
suspend fun processData(): List<Result> {
    return Flux.fromIterable(items)
        .flatMap { item -> 
            processItem(item)
                .withCurrentTracing() // Propagate tracing to Mono
        }
        .collectList()
        .awaitSingle()
}
```

### Frontend Integration

Frontend should send `X-Trace-Id` header:

```typescript
// Generate trace ID on frontend
const traceId = crypto.randomUUID();

fetch('/api/posts', {
  headers: {
    'X-Trace-Id': traceId,
    'Content-Type': 'application/json'
  }
});
```

The backend will:
1. Accept the `X-Trace-Id` from frontend
2. Generate a `spanId` for this request
3. Return both in response headers
4. Log all operations with these IDs

## Log Output

With the configured `logback-spring.xml`, logs will include:

```
2024-10-13T10:30:45.123+00:00 INFO  12345 --- [app] [trace=550e8400-e29b-41d4-a716-446655440000 span=a1b2c3d4e5f6g7h8] [reactor-http-nio-2] c.j.be.post.PostController : Fetching post: 123
```

JSON logs will include:

```json
{
  "timestamp": "2024-10-13T10:30:45.123Z",
  "level": "INFO",
  "logger": "com.jirihermann.be.post.PostController",
  "message": "Fetching post: 123",
  "traceId": "550e8400-e29b-41d4-a716-446655440000",
  "spanId": "a1b2c3d4e5f6g7h8"
}
```

## How It Works

1. **Request arrives** → `TracingWebFilter` extracts/generates trace IDs
2. **Reactor Context** → IDs stored in Reactor Context
3. **WebFlux Handler** → Coroutine starts with `ReactorContext` element
4. **MDC Propagation** → `MDCContext` and `TracingContextElement` propagate through coroutines
5. **Logging** → MDC values automatically included in all logs
6. **Response** → Trace IDs added to response headers

## Best Practices

1. **Always use `withTracing {}`** in service methods to ensure proper MDC setup
2. **Use `withChildSpan()`** for sub-operations to track nested work
3. **Don't manually set MDC** - let the framework handle it
4. **Frontend should generate trace IDs** before making requests
5. **Log at appropriate levels** - trace IDs help with debugging

## Troubleshooting

### Trace ID not appearing in logs

- Check that `TracingWebFilter` is loaded (order -100)
- Verify `MDCContext` is in your coroutine context
- Use `withTracing {}` wrapper in service methods

### Trace ID not propagating to async operations

- Use `withCurrentTracing()` when creating Mono/Flux from coroutines
- Ensure `MdcContextLifter` is loaded as a component

### Different trace IDs in same request

- Make sure you're not creating new contexts accidentally
- Use `withChildSpan()` instead of creating new `TracingContext`




