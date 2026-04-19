package com.jirihermann.be.kotlinlearning

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException

@RestController
@RequestMapping("/api/learn-kotlin")
@Tag(name = "Kotlin Learning", description = "Interactive Kotlin learning platform for Java and C# developers")
class KotlinLearningController(
    private val service: KotlinLearningService,
    private val playgroundService: KotlinPlaygroundService
) {

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

    // =====================================================
    // Tiered Content Endpoints
    // =====================================================

    @GetMapping("/topics/{id}/tiered")
    @Operation(
        summary = "Get topic with tiered content",
        description = "Returns topic with multi-level explanations: TL;DR, Beginner, Intermediate, Deep Dive"
    )
    suspend fun getTopicWithTiers(
        @PathVariable id: String,
        @Parameter(
            description = "Source language for code comparisons: 'java' or 'csharp'",
            example = "java"
        )
        @RequestParam(required = false) sourceLanguage: String?,
        @Parameter(
            description = "Tier level (1-4). If not specified, returns all available tiers.",
            example = "2"
        )
        @RequestParam(required = false) tier: Int?
    ): KotlinTopicWithTiersDto {
        return service.getTopicWithTiers(id, sourceLanguage, tier)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Topic not found: $id")
    }

    // =====================================================
    // Expense Tracker Journey Endpoints
    // =====================================================

    @GetMapping("/expense-tracker/chapters")
    @Operation(
        summary = "List expense tracker chapters",
        description = "Returns all chapters of the expense tracker tutorial journey"
    )
    suspend fun listExpenseTrackerChapters() = service.listExpenseTrackerChapters()

    @GetMapping("/expense-tracker/chapters/{chapterNumber}")
    @Operation(
        summary = "Get expense tracker chapter",
        description = "Returns full chapter content with linked topics and implementation steps"
    )
    suspend fun getExpenseTrackerChapter(
        @PathVariable chapterNumber: Int
    ): ExpenseTrackerChapterDetailDto {
        return service.getExpenseTrackerChapter(chapterNumber)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Chapter not found: $chapterNumber")
    }

    // =====================================================
    // Code Execution Endpoint
    // =====================================================

    @PostMapping("/execute")
    @Operation(
        summary = "Execute Kotlin code",
        description = "Executes Kotlin code via the Kotlin Playground API and returns the output"
    )
    suspend fun executeCode(
        @RequestBody request: ExecuteCodeRequest
    ): ExecuteCodeResponse {
        return playgroundService.executeCode(request.code)
    }

    // =====================================================
    // Admin Endpoints - Topics (requires ROLE_ADMIN)
    // =====================================================

    @GetMapping("/admin/topics")
    @Operation(
        summary = "List all topics for admin",
        description = "Returns all topics with full details for admin management"
    )
    suspend fun listTopicsAdmin() = service.listTopicsAdmin()

    @GetMapping("/admin/topics/{id}")
    @Operation(
        summary = "Get topic for admin editing",
        description = "Returns topic with all fields for admin editing"
    )
    suspend fun getTopicAdmin(@PathVariable id: String): KotlinTopicAdminDto {
        return service.getTopicAdmin(id)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Topic not found: $id")
    }

    @PostMapping("/topics")
    @Operation(
        summary = "Create a new topic",
        description = "Creates a new Kotlin learning topic (requires ADMIN role)"
    )
    suspend fun createTopic(@RequestBody request: KotlinTopicUpsertRequest): Map<String, String> {
        val id = service.createTopic(request)
        return mapOf("id" to id)
    }

    @PutMapping("/topics/{id}")
    @Operation(
        summary = "Update a topic",
        description = "Updates an existing Kotlin learning topic (requires ADMIN role)"
    )
    suspend fun updateTopic(
        @PathVariable id: String,
        @RequestBody request: KotlinTopicUpsertRequest
    ) {
        if (id != request.id) {
            throw ResponseStatusException(HttpStatus.BAD_REQUEST, "ID in path must match ID in request body")
        }
        service.updateTopic(id, request)
    }

    @DeleteMapping("/topics/{id}")
    @Operation(
        summary = "Delete a topic",
        description = "Deletes a Kotlin learning topic (requires ADMIN role)"
    )
    suspend fun deleteTopic(@PathVariable id: String) {
        service.deleteTopic(id)
    }

    // =====================================================
    // Admin Endpoints - Expense Tracker Chapters (requires ROLE_ADMIN)
    // =====================================================

    @GetMapping("/admin/chapters")
    @Operation(
        summary = "List all chapters for admin",
        description = "Returns all chapters with full details for admin management"
    )
    suspend fun listChaptersAdmin() = service.listChaptersAdmin()

    @GetMapping("/admin/chapters/{id}")
    @Operation(
        summary = "Get chapter for admin editing",
        description = "Returns chapter with all fields for admin editing"
    )
    suspend fun getChapterAdmin(@PathVariable id: Int): ExpenseTrackerChapterAdminDto {
        return service.getChapterAdmin(id)
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND, "Chapter not found: $id")
    }

    @PostMapping("/chapters")
    @Operation(
        summary = "Create a new chapter",
        description = "Creates a new expense tracker chapter (requires ADMIN role)"
    )
    suspend fun createChapter(@RequestBody request: ExpenseTrackerChapterUpsertRequest): Map<String, Int> {
        val id = service.createChapter(request)
        return mapOf("id" to id)
    }

    @PutMapping("/chapters/{id}")
    @Operation(
        summary = "Update a chapter",
        description = "Updates an existing expense tracker chapter (requires ADMIN role)"
    )
    suspend fun updateChapter(
        @PathVariable id: Int,
        @RequestBody request: ExpenseTrackerChapterUpsertRequest
    ) {
        service.updateChapter(id, request)
    }

    @DeleteMapping("/chapters/{id}")
    @Operation(
        summary = "Delete a chapter",
        description = "Deletes an expense tracker chapter (requires ADMIN role)"
    )
    suspend fun deleteChapter(@PathVariable id: Int) {
        service.deleteChapter(id)
    }
}
