package com.jirihermann.be.meta

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/meta")
@Tag(name = "Meta")
class MetaController(private val service: MetaService) {
  @GetMapping
  @Operation(summary = "Get site meta (public)")
  suspend fun get() = service.get()
}


