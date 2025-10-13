# ---- Build ----
FROM gradle:8.10-jdk21-alpine AS build
WORKDIR /workspace
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle ./gradle
RUN ./gradlew --version
COPY src ./src
RUN ./gradlew clean bootJar -x test

# ---- Runtime ----
FROM eclipse-temurin:21-jre-alpine

# Build arguments for version tracking
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# OCI Image labels for version tracking
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="Jiri Hermann" \
      org.opencontainers.image.url="https://jirihermann.com" \
      org.opencontainers.image.source="https://github.com/jirihermann/workspace-fullstack" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Jiri Hermann" \
      org.opencontainers.image.title="Personal Blog Backend" \
      org.opencontainers.image.description="Spring Boot backend for personal blog/portfolio"

WORKDIR /app
COPY --from=build /workspace/build/libs/*-SNAPSHOT.jar /app/app.jar

# Set environment variables for version info
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+UseZGC" \
    GIT_COMMIT="${VCS_REF}" \
    BUILD_TIME="${BUILD_DATE}"

EXPOSE 8891
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD wget -qO- http://localhost:8891/actuator/health | grep UP || exit 1
ENTRYPOINT ["java","-jar","/app/app.jar"]