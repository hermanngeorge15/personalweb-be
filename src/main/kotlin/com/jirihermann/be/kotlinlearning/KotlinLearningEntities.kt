package com.jirihermann.be.kotlinlearning

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table
import java.time.OffsetDateTime

@Table("kotlin_topic")
data class KotlinTopicEntity(
    @Id val id: String,
    val title: String,
    val module: String,
    val difficulty: String,
    val description: String?,
    val kotlin_explanation: String,
    val kotlin_code: String,
    val reading_time_minutes: Int = 10,
    val order_index: Int = 0,
    val content_structure: String = "flat", // flat or tiered
    val max_tier_level: Int = 1, // 1-4
    val part_number: Int = 1,
    val part_name: String? = null,
    val created_at: OffsetDateTime = OffsetDateTime.now(),
    val updated_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_code_example")
data class KotlinCodeExampleEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val language: String,
    val version_label: String?,
    val code: String,
    val explanation: String,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_experience")
data class KotlinExperienceEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val title: String,
    val content: String,
    val experience_type: String,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_doc_link")
data class KotlinDocLinkEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val link_type: String,
    val url: String,
    val title: String,
    val description: String?,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_topic_dependency")
data class KotlinTopicDependencyEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val depends_on_topic_id: String,
    val dependency_type: String,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

// Content tier for multi-level explanations
@Table("kotlin_content_tier")
data class KotlinContentTierEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val tier_level: Int, // 1=TL;DR, 2=Beginner, 3=Intermediate, 4=Deep Dive
    val tier_name: String,
    val title: String?,
    val explanation: String,
    val code_examples: String?, // JSON array
    val reading_time_minutes: Int = 5,
    val learning_objectives: String?, // JSON array
    val prerequisites: String?, // JSON array of topic IDs
    val created_at: OffsetDateTime = OffsetDateTime.now(),
    val updated_at: OffsetDateTime = OffsetDateTime.now()
)

// Runnable examples for Kotlin Playground
@Table("kotlin_runnable_example")
data class KotlinRunnableExampleEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val tier_level: Int = 1,
    val title: String,
    val description: String?,
    val code: String,
    val expected_output: String?,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

// Expense Tracker tutorial chapters
@Table("kotlin_expense_tracker_chapter")
data class KotlinExpenseTrackerChapterEntity(
    @Id val id: Int? = null,
    val chapter_number: Int,
    val title: String,
    val description: String?,
    val topic_ids: String?, // JSON array
    val introduction: String?,
    val implementation_steps: String?, // JSON array
    val code_snippets: String?, // JSON array
    val summary: String?,
    val previous_chapter: Int?,
    val next_chapter: Int?,
    val estimated_time_minutes: Int = 30,
    val difficulty: String = "beginner",
    val created_at: OffsetDateTime = OffsetDateTime.now(),
    val updated_at: OffsetDateTime = OffsetDateTime.now()
)

// Link between topics and expense tracker chapters
@Table("kotlin_topic_chapter_link")
data class KotlinTopicChapterLinkEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val chapter_id: Int,
    val usage_type: String = "primary", // primary, secondary, reference
    val context_description: String?,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)
