## Project
Spring Boot 3.3 reactive backend in Kotlin 2.0 on Java 21. WebFlux + R2DBC (PostgreSQL),
Flyway migrations (JDBC), Lettuce/Redis reactive, OAuth2 resource server (Keycloak),
Micrometer + OTLP tracing, AWS SES email, Thymeleaf + openhtmltopdf for PDF rendering.
Gradle Kotlin DSL, single-module.

## Build Commands
- `./gradlew build` — compile + test
- `./gradlew test` — tests only (JUnit 5 + MockK + Testcontainers)
- `./gradlew compileKotlin` — fast compile check
- `./gradlew bootRun` — start locally (reads env.example)
- `./gradlew flywayInfo` — inspect migration state

## Hard Rules
- Never run `./gradlew flywayMigrate` / `flywayClean` — ask the user to run migrations
- Use coroutines + reactive (`suspend`, `Mono`, `Flux`); never block (`runBlocking`, `Thread.sleep`)
- R2DBC for runtime DB access; JDBC only for Flyway
- Sanitize rich text with jsoup before persisting
- Never commit secrets — config lives in env.example / k8s secrets
- Write tests for new service/controller logic; use MockK for mocks

## Conventions
- Package root: `com.jirihermann`
- Tests: same package under `src/test/kotlin`, named `*Test.kt`, `should … when …`
- Use `@ConfigurationProperties` over `@Value` for grouped config
- Structured logging via Logstash encoder — include `traceId` where available
