package com.jirihermann.be.kotlinlearning

import java.time.OffsetDateTime

// Topic DTOs
data class KotlinTopicListItemDto(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val readingTimeMinutes: Int
)

data class KotlinTopicDetailDto(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val kotlinExplanation: String,
    val kotlinCode: String,
    val readingTimeMinutes: Int,
    val codeExamples: List<KotlinCodeExampleDto>,
    val experiences: List<KotlinExperienceDto>,
    val docLinks: List<KotlinDocLinkDto>,
    val navigation: TopicNavigationDto?
)

data class TopicNavigationDto(
    val previous: String?,
    val next: String?
)

// Code example DTOs
data class KotlinCodeExampleDto(
    val language: String,
    val versionLabel: String?,
    val code: String,
    val explanation: String
)

// Experience DTOs
data class KotlinExperienceDto(
    val title: String,
    val content: String,
    val type: String
)

// Documentation link DTOs
data class KotlinDocLinkDto(
    val type: String,
    val url: String,
    val title: String,
    val description: String?
)

// Mind map DTOs
data class MindMapDto(
    val topics: List<MindMapTopicDto>,
    val dependencies: List<MindMapDependencyDto>
)

data class MindMapTopicDto(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String
)

data class MindMapDependencyDto(
    val from: String,
    val to: String,
    val type: String
)

// Module grouping DTO
data class ModuleDto(
    val name: String,
    val topics: List<KotlinTopicListItemDto>
)

// =====================================================
// Tiered Content DTOs
// =====================================================

// Content tier DTO (one level of explanation)
data class KotlinContentTierDto(
    val tierLevel: Int, // 1=TL;DR, 2=Beginner, 3=Intermediate, 4=Deep Dive
    val tierName: String,
    val title: String?,
    val explanation: String,
    val codeExamples: List<String>?, // Parsed from JSON
    val readingTimeMinutes: Int,
    val learningObjectives: List<String>?,
    val prerequisites: List<String>?
)

// Runnable example DTO (for Kotlin Playground)
data class KotlinRunnableExampleDto(
    val title: String,
    val description: String?,
    val code: String,
    val expectedOutput: String?,
    val tierLevel: Int
)

// Topic with tiered content
data class KotlinTopicWithTiersDto(
    val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val partNumber: Int,
    val partName: String?,
    val contentStructure: String, // flat or tiered
    val maxTierLevel: Int,
    val availableTiers: List<Int>,
    val tiers: List<KotlinContentTierDto>,
    val runnableExamples: List<KotlinRunnableExampleDto>,
    val codeExamples: List<KotlinCodeExampleDto>, // Language comparisons
    val experiences: List<KotlinExperienceDto>,
    val docLinks: List<KotlinDocLinkDto>,
    val navigation: TopicNavigationDto?,
    val expenseTrackerChapters: List<ExpenseTrackerChapterRefDto>? // Which chapters use this topic
)

// Reference to an expense tracker chapter
data class ExpenseTrackerChapterRefDto(
    val chapterNumber: Int,
    val title: String,
    val usageType: String,
    val contextDescription: String?
)

// =====================================================
// Expense Tracker Journey DTOs
// =====================================================

// Chapter list item
data class ExpenseTrackerChapterListDto(
    val chapterNumber: Int,
    val title: String,
    val description: String?,
    val difficulty: String,
    val estimatedTimeMinutes: Int,
    val topicCount: Int
)

// Full chapter detail
data class ExpenseTrackerChapterDetailDto(
    val chapterNumber: Int,
    val title: String,
    val description: String?,
    val introduction: String?,
    val implementationSteps: List<String>?,
    val codeSnippets: List<ExpenseTrackerCodeSnippetDto>?,
    val summary: String?,
    val difficulty: String,
    val estimatedTimeMinutes: Int,
    val topics: List<ExpenseTrackerTopicRefDto>,
    val navigation: ChapterNavigationDto?
)

// Code snippet in a chapter
data class ExpenseTrackerCodeSnippetDto(
    val title: String?,
    val code: String,
    val explanation: String?
)

// Topic reference from a chapter
data class ExpenseTrackerTopicRefDto(
    val topicId: String,
    val topicTitle: String,
    val usageType: String,
    val contextDescription: String?
)

// Chapter navigation
data class ChapterNavigationDto(
    val previous: Int?,
    val next: Int?
)
