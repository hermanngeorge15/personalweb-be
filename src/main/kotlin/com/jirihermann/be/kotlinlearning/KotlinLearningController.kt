package com.jirihermann.be.kotlinlearning

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException

@RestController
@RequestMapping("/api/learn-kotlin")
@Tag(name = "Kotlin Learning", description = "Interactive Kotlin learning platform for Java and C# developers")
class KotlinLearningController(private val service: KotlinLearningService) {

    @GetMapping("/topics")
    @Operation(
        summary = "List all topics",
        description = "Returns all Kotlin learning topics ordered by learning sequence"
    )
    suspend fun listTopics() = service.listTopics()

    @GetMapping("/topics/by-module")
    @Operation(
        summary = "List topics grouped by module",
        description = "Returns topics organized by their module (OOP Fundamentals, Class Types, etc.)"
    )
    suspend fun listTopicsByModule() = service.listTopicsByModule()

    @GetMapping("/topics/{id}")
    @Operation(
        summary = "Get topic details",
        description = "Returns full topic content with code examples filtered by source language"
    )
    suspend fun getTopic(
        @PathVariable id: String,
        @Parameter(
            description = "Source language for code comparisons: 'java' or 'csharp'. If not specified, returns all examples.",
            example = "java"
        )
        @RequestParam(required = false) sourceLanguage: String?
    ): KotlinTopicDetailDto {
        return service.getTopic(id, sourceLanguage)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Topic not found: $id")
    }

    @GetMapping("/mindmap")
    @Operation(
        summary = "Get mind map data",
        description = "Returns all topics and their dependencies for rendering the interactive mind map"
    )
    suspend fun getMindMap() = service.getMindMap()
}
