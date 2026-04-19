package com.jirihermann.be.kotlinlearning

data class KotlinTopicUpsertRequest(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val kotlinExplanation: String,
    val kotlinCode: String,
    val readingTimeMinutes: Int = 10,
    val orderIndex: Int = 0,
    val partNumber: Int? = null,
    val partName: String? = null,
    val contentStructure: String = "tiered",
    val maxTierLevel: Int = 2
)

data class ExpenseTrackerChapterUpsertRequest(
    val chapterNumber: Int,
    val title: String,
    val description: String?,
    val introduction: String?,
    val implementationSteps: String?,  // JSON array as string
    val codeSnippets: String?,         // JSON array as string
    val summary: String?,
    val difficulty: String = "beginner",
    val estimatedTimeMinutes: Int = 30
)

// Response DTOs for admin operations
data class KotlinTopicAdminDto(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val kotlinExplanation: String,
    val kotlinCode: String,
    val readingTimeMinutes: Int,
    val orderIndex: Int,
    val partNumber: Int?,
    val partName: String?,
    val contentStructure: String?,
    val maxTierLevel: Int
)

data class ExpenseTrackerChapterAdminDto(
    val id: Int,
    val chapterNumber: Int,
    val title: String,
    val description: String?,
    val introduction: String?,
    val implementationSteps: String?,
    val codeSnippets: String?,
    val summary: String?,
    val difficulty: String,
    val estimatedTimeMinutes: Int,
    val previousChapter: Int?,
    val nextChapter: Int?
)
