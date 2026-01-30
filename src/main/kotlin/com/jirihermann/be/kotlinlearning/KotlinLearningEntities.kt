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
    val part_number: Int? = null,
    val part_name: String? = null,
    val content_structure: String? = "tiered",
    val max_tier_level: Int = 2,
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

@Table("kotlin_content_tier")
data class KotlinContentTierEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val tier_level: Int,
    val tier_name: String,
    val title: String?,
    val explanation: String,
    val code_examples: String? = null,
    val reading_time_minutes: Int = 5,
    val learning_objectives: String? = null,
    val prerequisites: String? = null,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_runnable_example")
data class KotlinRunnableExampleEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val title: String,
    val description: String?,
    val code: String,
    val expected_output: String?,
    val tier_level: Int = 2,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_expense_tracker_chapter")
data class KotlinExpenseTrackerChapterEntity(
    @Id val id: Int? = null,
    val chapter_number: Int,
    val title: String,
    val description: String?,
    val introduction: String?,
    val implementation_steps: String?,
    val code_snippets: String?,
    val summary: String?,
    val difficulty: String = "beginner",
    val estimated_time_minutes: Int = 30,
    val previous_chapter: Int?,
    val next_chapter: Int?,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)

@Table("kotlin_topic_chapter_link")
data class KotlinTopicChapterLinkEntity(
    @Id val id: Int? = null,
    val topic_id: String,
    val chapter_id: Int,
    val usage_type: String,
    val context_description: String?,
    val order_index: Int = 0,
    val created_at: OffsetDateTime = OffsetDateTime.now()
)
