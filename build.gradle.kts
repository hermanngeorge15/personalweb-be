import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
  kotlin("jvm") version "2.0.0"
  kotlin("plugin.spring") version "2.0.0"
  id("org.springframework.boot") version "3.3.4"
  id("io.spring.dependency-management") version "1.1.6"
  id("org.flywaydb.flyway") version "9.22.3"
}

group = "com.jirihermann"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_21

repositories {
  mavenCentral()
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
  implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
  implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
  implementation("org.springframework.boot:spring-boot-starter-validation")
  implementation("org.springframework.boot:spring-boot-starter-actuator")
  implementation("io.micrometer:micrometer-registry-prometheus")

  implementation("org.jetbrains.kotlin:kotlin-reflect")
  implementation("org.flywaydb:flyway-core")
  implementation("org.flywaydb:flyway-database-postgresql:10.10.0")
  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor:1.9.0")
  implementation("io.micrometer:micrometer-tracing-bridge-otel") // or :micrometer-tracing-bridge-brave
  implementation("io.opentelemetry:opentelemetry-exporter-otlp") // optional exporter
  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-slf4j:1.9.0")
  implementation("org.springframework.boot:spring-boot-starter-data-r2dbc")
  runtimeOnly("org.postgresql:postgresql")
  runtimeOnly("org.postgresql:r2dbc-postgresql")


    implementation("org.springframework.boot:spring-boot-starter-data-redis-reactive")
    implementation("io.lettuce:lettuce-core")

  implementation("net.logstash.logback:logstash-logback-encoder:7.4")

  implementation("org.springdoc:springdoc-openapi-starter-webflux-ui:2.6.0")

  // HTML -> PDF rendering
  implementation("com.openhtmltopdf:openhtmltopdf-core:1.0.10")
  implementation("com.openhtmltopdf:openhtmltopdf-pdfbox:1.0.10")

  // Sanitization for rich text fields
  implementation("org.jsoup:jsoup:1.17.2")

  // AWS SES for email sending
  implementation(platform("software.amazon.awssdk:bom:2.20.150"))
  implementation("software.amazon.awssdk:ses")
  implementation("software.amazon.awssdk:netty-nio-client")

  testImplementation("org.springframework.boot:spring-boot-starter-test")
  testImplementation("io.projectreactor:reactor-test")
  testImplementation("org.testcontainers:junit-jupiter")
  testImplementation("org.testcontainers:postgresql")
  testImplementation("io.mockk:mockk:1.13.12")
  testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.9.0")
}

tasks.withType<KotlinCompile> {
  compilerOptions {
    jvmTarget.set(JvmTarget.JVM_21)
    freeCompilerArgs.addAll("-Xjsr305=strict")
  }
}

tasks.withType<Test> {
  useJUnitPlatform()
}

flyway {
  url = System.getenv("FLYWAY_URL") ?: "jdbc:postgresql://localhost:5432/personal"
  user = System.getenv("FLYWAY_USER") ?: "personal"
  password = System.getenv("FLYWAY_PASSWORD") ?: "personal"
}


