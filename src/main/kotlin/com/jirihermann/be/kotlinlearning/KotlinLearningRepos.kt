package com.jirihermann.be.kotlinlearning

import kotlinx.coroutines.flow.Flow
import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository

interface KotlinTopicRepo : CoroutineCrudRepository<KotlinTopicEntity, String> {
    @Query("SELECT * FROM kotlin_topic ORDER BY order_index ASC")
    fun findAllOrderedByIndex(): Flow<KotlinTopicEntity>

    @Query("SELECT * FROM kotlin_topic WHERE module = :module ORDER BY order_index ASC")
    fun findByModule(module: String): Flow<KotlinTopicEntity>
}

interface KotlinCodeExampleRepo : CoroutineCrudRepository<KotlinCodeExampleEntity, Int> {
    @Query("SELECT * FROM kotlin_code_example WHERE topic_id = :topicId ORDER BY order_index ASC")
    fun findByTopicId(topicId: String): Flow<KotlinCodeExampleEntity>

    @Query("SELECT * FROM kotlin_code_example WHERE topic_id = :topicId AND language = :language ORDER BY order_index ASC")
    fun findByTopicIdAndLanguage(topicId: String, language: String): Flow<KotlinCodeExampleEntity>

    @Query("SELECT * FROM kotlin_code_example WHERE topic_id = :topicId AND language LIKE 'java%' ORDER BY order_index ASC")
    fun findJavaExamplesByTopicId(topicId: String): Flow<KotlinCodeExampleEntity>

    @Query("SELECT * FROM kotlin_code_example WHERE topic_id = :topicId AND language = 'csharp' ORDER BY order_index ASC")
    fun findCsharpExamplesByTopicId(topicId: String): Flow<KotlinCodeExampleEntity>
}

interface KotlinExperienceRepo : CoroutineCrudRepository<KotlinExperienceEntity, Int> {
    @Query("SELECT * FROM kotlin_experience WHERE topic_id = :topicId ORDER BY order_index ASC")
    fun findByTopicId(topicId: String): Flow<KotlinExperienceEntity>
}

interface KotlinDocLinkRepo : CoroutineCrudRepository<KotlinDocLinkEntity, Int> {
    @Query("SELECT * FROM kotlin_doc_link WHERE topic_id = :topicId ORDER BY order_index ASC")
    fun findByTopicId(topicId: String): Flow<KotlinDocLinkEntity>

    @Query("SELECT * FROM kotlin_doc_link WHERE topic_id = :topicId AND link_type IN ('kotlin_official', 'java_official', 'kotlinprimer', 'other') ORDER BY order_index ASC")
    fun findJavaRelevantByTopicId(topicId: String): Flow<KotlinDocLinkEntity>

    @Query("SELECT * FROM kotlin_doc_link WHERE topic_id = :topicId AND link_type IN ('kotlin_official', 'csharp_official', 'kotlinprimer', 'other') ORDER BY order_index ASC")
    fun findCsharpRelevantByTopicId(topicId: String): Flow<KotlinDocLinkEntity>
}

interface KotlinTopicDependencyRepo : CoroutineCrudRepository<KotlinTopicDependencyEntity, Int> {
    @Query("SELECT * FROM kotlin_topic_dependency WHERE topic_id = :topicId")
    fun findByTopicId(topicId: String): Flow<KotlinTopicDependencyEntity>

    @Query("SELECT * FROM kotlin_topic_dependency")
    fun findAllDependencies(): Flow<KotlinTopicDependencyEntity>
}
