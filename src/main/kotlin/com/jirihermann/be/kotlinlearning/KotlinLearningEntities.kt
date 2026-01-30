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
