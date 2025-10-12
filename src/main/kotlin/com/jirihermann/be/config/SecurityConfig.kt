package com.jirihermann.be.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.env.Environment
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.web.server.SecurityWebFilterChain
import org.springframework.security.web.server.header.ReferrerPolicyServerHttpHeadersWriter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.reactive.CorsConfigurationSource
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource
import org.springframework.core.convert.converter.Converter
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverterAdapter
import reactor.core.publisher.Mono

@Configuration
@EnableWebFluxSecurity
class SecurityConfig(
  @Value("\${security.allowed-origins:http://localhost:3000,http://localhost:3333}")
  private val allowedOrigins: String,
  
  @Value("\${security.cors.max-age:3600}")
  private val corsMaxAge: Long = 3600,
  
  @Value("\${security.cors.enabled:true}")
  private val corsEnabled: Boolean = true,
  
  private val environment: Environment
) {

  @Bean
  fun filterChain(http: ServerHttpSecurity): SecurityWebFilterChain =
    http
      // CSRF disabled for stateless JWT API
      .csrf { it.disable() }
      
      // Enable CORS (can be disabled for same-origin deployments)
      .apply {
        if (corsEnabled) {
          cors { }
        }
      }
      
      // Security headers
      .headers { headers ->
        headers
          .frameOptions { it.disable() } // API doesn't need frame protection
          .contentSecurityPolicy { csp ->
            csp.policyDirectives("default-src 'none'; frame-ancestors 'none'")
          }
          .referrerPolicy { referrer ->
            referrer.policy(ReferrerPolicyServerHttpHeadersWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN)
          }
      }
      
      // Authorization rules
      .authorizeExchange { exchanges ->
        // Health checks - always public
        exchanges.pathMatchers(
          "/actuator/health",
          "/actuator/health/liveness",
          "/actuator/health/readiness"
        ).permitAll()
        
        // Prometheus metrics - public for now, consider protecting in production
        exchanges.pathMatchers("/actuator/prometheus", "/actuator/metrics/**").permitAll()
        
        // OpenAPI/Swagger - public for now, consider protecting in production
        exchanges.pathMatchers(
          "/swagger-ui.html",
          "/swagger-ui/**",
          "/v3/api-docs",
          "/v3/api-docs/**",
          "/webjars/**"
        ).permitAll()
        
        // Admin-only endpoints
        exchanges.pathMatchers(HttpMethod.GET, "/api/contact").hasRole("ADMIN")
        exchanges.pathMatchers(HttpMethod.POST, "/api/contact/*/handle").hasRole("ADMIN")
        
        // Public GET endpoints
        exchanges.pathMatchers(HttpMethod.GET, "/api/posts", "/api/posts/**").permitAll()
        exchanges.pathMatchers(HttpMethod.GET, "/api/projects", "/api/projects/**").permitAll()
        exchanges.pathMatchers(HttpMethod.GET, "/api/testimonials", "/api/testimonials/**").permitAll()
        exchanges.pathMatchers(HttpMethod.GET, "/api/resume", "/api/resume/**").permitAll()
        exchanges.pathMatchers(HttpMethod.GET, "/api/meta").permitAll()
        
        // Public POST endpoints
        exchanges.pathMatchers(HttpMethod.POST, "/api/contact").permitAll()
        
        // CV generation endpoints
        exchanges.pathMatchers("/cv/**").permitAll()
        
        // All other /api/** endpoints require ADMIN role
        exchanges.pathMatchers("/api/**").hasRole("ADMIN")
        
        // Deny everything else by default (security-first approach)
        exchanges.anyExchange().denyAll()
      }
      
      // OAuth2 Resource Server with JWT
      .oauth2ResourceServer { rs ->
        rs.jwt { jwtSpec ->
          jwtSpec.jwtAuthenticationConverter(jwtAuthConverter())
        }
        // Configure proper error handling
        rs.authenticationEntryPoint { exchange, _ ->
          exchange.response.statusCode = HttpStatus.UNAUTHORIZED
          Mono.empty()
        }
        rs.accessDeniedHandler { exchange, _ ->
          exchange.response.statusCode = HttpStatus.FORBIDDEN
          Mono.empty()
        }
      }
      .build()

  @Bean
  fun corsConfigurationSource(): CorsConfigurationSource {
    val config = CorsConfiguration()
    
    // Allow credentials (cookies, authorization headers)
    config.allowCredentials = true
    
    // Parse and add allowed origins
    val origins = allowedOrigins
      .split(',')
      .map { it.trim() }
      .filter { it.isNotEmpty() }
    
    if (corsEnabled && origins.isEmpty()) {
      throw IllegalStateException("No allowed origins configured. Set ALLOWED_ORIGINS environment variable or disable CORS.")
    }
    
    origins.forEach { origin ->
      // Validate origins in production
      val isProduction = environment.activeProfiles.contains("prod")
      if (isProduction && !origin.startsWith("https://")) {
        throw IllegalStateException("Production environment requires HTTPS origins. Invalid: $origin")
      }
      config.addAllowedOrigin(origin)
    }
    
    // Allowed methods - be explicit in production
    config.allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
    
    // Allowed headers - be explicit in production
    config.allowedHeaders = listOf(
      "Authorization",
      "Content-Type",
      "X-Requested-With",
      "Accept",
      "Origin",
      "Access-Control-Request-Method",
      "Access-Control-Request-Headers"
    )
    
    // Expose headers that frontend needs to read
    config.exposedHeaders = listOf(
      "Access-Control-Allow-Origin",
      "Access-Control-Allow-Credentials"
    )
    
    // Cache preflight requests (1 hour)
    config.maxAge = corsMaxAge
    
    val source = UrlBasedCorsConfigurationSource()
    source.registerCorsConfiguration("/**", config)
    
    return source
  }
}

private fun jwtAuthConverter(): Converter<Jwt, Mono<AbstractAuthenticationToken>> {
  val authConverter = JwtAuthenticationConverter()
  authConverter.setJwtGrantedAuthoritiesConverter { jwt -> extractAuthorities(jwt) }
  return ReactiveJwtAuthenticationConverterAdapter(authConverter)
}

private fun extractAuthorities(jwt: Jwt): Collection<GrantedAuthority> {
  val authorities = mutableSetOf<GrantedAuthority>()

  // realm roles
  val realmAccess = jwt.getClaimAsMap("realm_access")
  val realmRoles = (realmAccess?.get("roles") as? Collection<*>)?.filterIsInstance<String>().orEmpty()
  realmRoles.forEach { role -> authorities.add(SimpleGrantedAuthority("ROLE_${role.uppercase()}")) }

  // client roles
  val resourceAccess = jwt.getClaimAsMap("resource_access")
  resourceAccess?.forEach { (_, v) ->
    val roles = (if (v is Map<*, *>) v["roles"] else null) as? Collection<*>
    roles?.filterIsInstance<String>()?.forEach { role ->
      authorities.add(SimpleGrantedAuthority("ROLE_${role.uppercase()}"))
    }
  }

  return authorities
}


