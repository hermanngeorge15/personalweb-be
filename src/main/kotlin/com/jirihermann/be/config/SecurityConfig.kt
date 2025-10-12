package com.jirihermann.be.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.web.server.SecurityWebFilterChain
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
  @Value("\${security.allowed-origins:http://localhost:3333}")
  private val allowedOrigins: String
) {

  @Bean
  fun filterChain(http: ServerHttpSecurity): SecurityWebFilterChain =
    http
      .csrf { it.disable() }
      .cors { }
      .authorizeExchange {
        // Admin-only GET endpoint overrides
        it.pathMatchers(HttpMethod.GET, "/api/contact").hasRole("ADMIN")
        // Public GETs
        it.pathMatchers(HttpMethod.GET, "/api/**").permitAll()
        it.pathMatchers(HttpMethod.POST, "/api/contact").permitAll()
        it.pathMatchers("/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
        it.pathMatchers("/api/**").hasRole("ADMIN")
        it.anyExchange().permitAll()
      }
      .oauth2ResourceServer { rs -> rs.jwt { jwtSpec -> jwtSpec.jwtAuthenticationConverter(jwtAuthConverter()) } }
      .build()

  @Bean
  fun corsConfigurationSource(): CorsConfigurationSource {
    val config = CorsConfiguration()
    config.allowCredentials = true
    config.addAllowedHeader("*")
    config.addAllowedMethod("*")
    allowedOrigins.split(',').map { it.trim() }.filter { it.isNotEmpty() }.forEach { origin ->
      config.addAllowedOrigin(origin)
    }
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


