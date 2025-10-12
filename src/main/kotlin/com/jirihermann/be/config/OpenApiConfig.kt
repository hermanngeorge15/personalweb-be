package com.jirihermann.be.config

import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.security.SecurityScheme
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {
  @Bean
  fun customOpenAPI(): OpenAPI {
    val bearerSchemeName = "bearer-jwt"
    val components = Components().addSecuritySchemes(
      bearerSchemeName,
      SecurityScheme()
        .type(SecurityScheme.Type.HTTP)
        .scheme("bearer")
        .bearerFormat("JWT")
    )
    return OpenAPI()
      .info(
        Info()
          .title("Personal Site API")
          .version("v1")
          .description("Public endpoints plus admin CRUD for posts, projects, testimonials, and contact moderation.")
      )
      .components(components)
  }
}


