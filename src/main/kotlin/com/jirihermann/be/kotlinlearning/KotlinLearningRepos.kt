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

interface KotlinContentTierRepo : CoroutineCrudRepository<KotlinContentTierEntity, Int> {
    @Query("SELECT * FROM kotlin_content_tier WHERE topic_id = :topicId ORDER BY tier_level ASC")
    fun findByTopicId(topicId: String): Flow<KotlinContentTierEntity>

    @Query("SELECT * FROM kotlin_content_tier WHERE topic_id = :topicId AND tier_level <= :maxTier ORDER BY tier_level ASC")
    fun findByTopicIdUpToTier(topicId: String, maxTier: Int): Flow<KotlinContentTierEntity>
}

interface KotlinRunnableExampleRepo : CoroutineCrudRepository<KotlinRunnableExampleEntity, Int> {
    @Query("SELECT * FROM kotlin_runnable_example WHERE topic_id = :topicId ORDER BY order_index ASC")
    fun findByTopicId(topicId: String): Flow<KotlinRunnableExampleEntity>

    @Query("SELECT * FROM kotlin_runnable_example WHERE topic_id = :topicId AND tier_level <= :maxTier ORDER BY order_index ASC")
    fun findByTopicIdUpToTier(topicId: String, maxTier: Int): Flow<KotlinRunnableExampleEntity>
}

interface KotlinExpenseTrackerChapterRepo : CoroutineCrudRepository<KotlinExpenseTrackerChapterEntity, Int> {
    @Query("SELECT * FROM kotlin_expense_tracker_chapter ORDER BY chapter_number ASC")
    fun findAllOrdered(): Flow<KotlinExpenseTrackerChapterEntity>

    @Query("SELECT * FROM kotlin_expense_tracker_chapter WHERE chapter_number = :chapterNumber")
    suspend fun findByChapterNumber(chapterNumber: Int): KotlinExpenseTrackerChapterEntity?
}

interface KotlinTopicChapterLinkRepo : CoroutineCrudRepository<KotlinTopicChapterLinkEntity, Int> {
    @Query("SELECT * FROM kotlin_topic_chapter_link WHERE topic_id = :topicId ORDER BY order_index ASC")
    fun findByTopicId(topicId: String): Flow<KotlinTopicChapterLinkEntity>

    @Query("SELECT * FROM kotlin_topic_chapter_link WHERE chapter_id = :chapterId ORDER BY order_index ASC")
    fun findByChapterId(chapterId: Int): Flow<KotlinTopicChapterLinkEntity>
}
