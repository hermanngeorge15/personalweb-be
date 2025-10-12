package com.jirihermann.be.testimonial

import java.util.UUID
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@RestController
@RequestMapping("/api/testimonials")
@Tag(name = "Testimonials")
class TestimonialController(private val service: TestimonialService) {
  @GetMapping
  @Operation(summary = "List testimonials (public)")
  suspend fun list() = service.list()

  // Admin
  @PostMapping
  @Operation(summary = "Create testimonial", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun create(@RequestBody body: TestimonialService.TestimonialUpsertRequest) = mapOf("id" to service.create(body))

  @PutMapping("/{id}")
  @Operation(summary = "Update testimonial", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun update(@PathVariable id: UUID, @RequestBody body: TestimonialService.TestimonialUpsertRequest) = service.update(id, body)

  @DeleteMapping("/{id}")
  @Operation(summary = "Delete testimonial", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun delete(@PathVariable id: UUID) = service.delete(id)
}


