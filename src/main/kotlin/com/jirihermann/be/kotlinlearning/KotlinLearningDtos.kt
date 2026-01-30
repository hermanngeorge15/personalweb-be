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
