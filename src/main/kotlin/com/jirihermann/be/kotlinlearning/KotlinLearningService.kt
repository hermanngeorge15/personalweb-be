package com.jirihermann.be.kotlinlearning

import com.jirihermann.be.tracing.withTracing
import kotlinx.coroutines.flow.toList
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class KotlinLearningService(
    private val topicRepo: KotlinTopicRepo,
    private val codeExampleRepo: KotlinCodeExampleRepo,
    private val experienceRepo: KotlinExperienceRepo,
    private val docLinkRepo: KotlinDocLinkRepo,
    private val dependencyRepo: KotlinTopicDependencyRepo,
    private val contentTierRepo: KotlinContentTierRepo,
    private val runnableExampleRepo: KotlinRunnableExampleRepo,
    private val chapterRepo: KotlinExpenseTrackerChapterRepo,
    private val topicChapterLinkRepo: KotlinTopicChapterLinkRepo
) {
    private val logger = LoggerFactory.getLogger(KotlinLearningService::class.java)

    /**
     * Get all topics as a flat list
     */
    suspend fun listTopics(): List<KotlinTopicListItemDto> = withTracing {
        logger.info("Listing all Kotlin learning topics")
        val topics = topicRepo.findAllOrderedByIndex().toList()
        logger.info("Found {} topics", topics.size)
        topics.map { it.toListItemDto() }
    }

    /**
     * Get topics grouped by module
     */
    suspend fun listTopicsByModule(): List<ModuleDto> = withTracing {
        logger.info("Listing Kotlin learning topics by module")
        val topics = topicRepo.findAllOrderedByIndex().toList()
        val grouped = topics.groupBy { it.module }
        logger.info("Found {} modules with {} total topics", grouped.size, topics.size)
        grouped.map { (module, moduleTopics) ->
            ModuleDto(
                name = module,
                topics = moduleTopics.map { it.toListItemDto() }
            )
        }
    }

    /**
     * Get a single topic with full details
     * @param sourceLanguage "java" or "csharp" to filter code examples
     */
    suspend fun getTopic(id: String, sourceLanguage: String?): KotlinTopicDetailDto? = withTracing {
        logger.info("Fetching topic: id={}, sourceLanguage={}", id, sourceLanguage)

        val topic = topicRepo.findById(id)
        if (topic == null) {
            logger.info("Topic not found: {}", id)
            return@withTracing null
        }

        // Get code examples based on source language
        val codeExamples = when (sourceLanguage?.lowercase()) {
            "java" -> codeExampleRepo.findJavaExamplesByTopicId(id).toList()
            "csharp", "c#" -> codeExampleRepo.findCsharpExamplesByTopicId(id).toList()
            else -> codeExampleRepo.findByTopicId(id).toList()
        }

        // Get doc links based on source language
        val docLinks = when (sourceLanguage?.lowercase()) {
            "java" -> docLinkRepo.findJavaRelevantByTopicId(id).toList()
            "csharp", "c#" -> docLinkRepo.findCsharpRelevantByTopicId(id).toList()
            else -> docLinkRepo.findByTopicId(id).toList()
        }

        val experiences = experienceRepo.findByTopicId(id).toList()

        // Get navigation (previous/next topic)
        val allTopics = topicRepo.findAllOrderedByIndex().toList()
        val currentIndex = allTopics.indexOfFirst { it.id == id }
        val navigation = TopicNavigationDto(
            previous = allTopics.getOrNull(currentIndex - 1)?.id,
            next = allTopics.getOrNull(currentIndex + 1)?.id
        )

        logger.info("Topic found: id={}, title={}, examples={}, experiences={}",
            topic.id, topic.title, codeExamples.size, experiences.size)

        KotlinTopicDetailDto(
            id = topic.id,
            title = topic.title,
            module = topic.module,
            difficulty = topic.difficulty,
            description = topic.description,
            kotlinExplanation = topic.kotlin_explanation,
            kotlinCode = topic.kotlin_code,
            readingTimeMinutes = topic.reading_time_minutes,
            codeExamples = codeExamples.map { it.toDto() },
            experiences = experiences.map { it.toDto() },
            docLinks = docLinks.map { it.toDto() },
            navigation = navigation
        )
    }

    /**
     * Get mind map data (all topics with dependencies)
     */
    suspend fun getMindMap(): MindMapDto = withTracing {
        logger.info("Fetching mind map data")

        val topics = topicRepo.findAllOrderedByIndex().toList()
        val dependencies = dependencyRepo.findAllDependencies().toList()

        logger.info("Mind map: {} topics, {} dependencies", topics.size, dependencies.size)

        MindMapDto(
            topics = topics.map {
                MindMapTopicDto(
                    id = it.id,
                    title = it.title,
                    module = it.module,
                    difficulty = it.difficulty
                )
            },
            dependencies = dependencies.map {
                MindMapDependencyDto(
                    from = it.depends_on_topic_id,
                    to = it.topic_id,
                    type = it.dependency_type
                )
            }
        )
    }

    // Extension functions for mapping entities to DTOs
    private fun KotlinTopicEntity.toListItemDto() = KotlinTopicListItemDto(
        id = id,
        title = title,
        module = module,
        difficulty = difficulty,
        description = description,
        readingTimeMinutes = reading_time_minutes
    )

    private fun KotlinCodeExampleEntity.toDto() = KotlinCodeExampleDto(
        language = language,
        versionLabel = version_label,
        code = code,
        explanation = explanation
    )

    private fun KotlinExperienceEntity.toDto() = KotlinExperienceDto(
        title = title,
        content = content,
        type = experience_type
    )

    private fun KotlinDocLinkEntity.toDto() = KotlinDocLinkDto(
        type = link_type,
        url = url,
        title = title,
        description = description
    )

    // =====================================================
    // Tiered Content Methods
    // =====================================================

    /**
     * Get topic with tiered content
     * @param tier Optional tier level (1-4). If null, returns all tiers up to topic's max tier.
     */
    suspend fun getTopicWithTiers(
        id: String,
        sourceLanguage: String?,
        tier: Int? = null
    ): KotlinTopicWithTiersDto? = withTracing {
        logger.info("Fetching topic with tiers: id={}, tier={}, sourceLanguage={}", id, tier, sourceLanguage)

        val topic = topicRepo.findById(id) ?: return@withTracing null

        // Get tiers based on requested tier level
        val tiers = if (tier != null) {
            contentTierRepo.findByTopicIdUpToTier(id, tier).toList()
        } else {
            contentTierRepo.findByTopicId(id).toList()
        }

        // Get runnable examples
        val runnableExamples = if (tier != null) {
            runnableExampleRepo.findByTopicIdUpToTier(id, tier).toList()
        } else {
            runnableExampleRepo.findByTopicId(id).toList()
        }

        // Get code examples (language comparisons)
        val codeExamples = when (sourceLanguage?.lowercase()) {
            "java" -> codeExampleRepo.findJavaExamplesByTopicId(id).toList()
            "csharp", "c#" -> codeExampleRepo.findCsharpExamplesByTopicId(id).toList()
            else -> codeExampleRepo.findByTopicId(id).toList()
        }

        // Get doc links
        val docLinks = when (sourceLanguage?.lowercase()) {
            "java" -> docLinkRepo.findJavaRelevantByTopicId(id).toList()
            "csharp", "c#" -> docLinkRepo.findCsharpRelevantByTopicId(id).toList()
            else -> docLinkRepo.findByTopicId(id).toList()
        }

        val experiences = experienceRepo.findByTopicId(id).toList()

        // Get navigation
        val allTopics = topicRepo.findAllOrderedByIndex().toList()
        val currentIndex = allTopics.indexOfFirst { it.id == id }
        val navigation = TopicNavigationDto(
            previous = allTopics.getOrNull(currentIndex - 1)?.id,
            next = allTopics.getOrNull(currentIndex + 1)?.id
        )

        // Get expense tracker chapter links
        val chapterLinks = topicChapterLinkRepo.findByTopicId(id).toList()
        val chapterRefs = chapterLinks.mapNotNull { link ->
            chapterRepo.findById(link.chapter_id)?.let { chapter ->
                ExpenseTrackerChapterRefDto(
                    chapterNumber = chapter.chapter_number,
                    title = chapter.title,
                    usageType = link.usage_type,
                    contextDescription = link.context_description
                )
            }
        }

        KotlinTopicWithTiersDto(
            id = topic.id,
            title = topic.title,
            module = topic.module,
            difficulty = topic.difficulty,
            description = topic.description,
            partNumber = topic.part_number,
            partName = topic.part_name,
            contentStructure = topic.content_structure,
            maxTierLevel = topic.max_tier_level,
            availableTiers = tiers.map { it.tier_level },
            tiers = tiers.map { it.toDto() },
            runnableExamples = runnableExamples.map { it.toDto() },
            codeExamples = codeExamples.map { it.toDto() },
            experiences = experiences.map { it.toDto() },
            docLinks = docLinks.map { it.toDto() },
            navigation = navigation,
            expenseTrackerChapters = chapterRefs.ifEmpty { null }
        )
    }

    // =====================================================
    // Expense Tracker Chapter Methods
    // =====================================================

    /**
     * List all expense tracker chapters
     */
    suspend fun listExpenseTrackerChapters(): List<ExpenseTrackerChapterListDto> = withTracing {
        logger.info("Listing expense tracker chapters")
        val chapters = chapterRepo.findAllOrdered().toList()

        chapters.map { chapter ->
            val topicCount = topicChapterLinkRepo.findByChapterId(chapter.id!!).toList().size
            ExpenseTrackerChapterListDto(
                chapterNumber = chapter.chapter_number,
                title = chapter.title,
                description = chapter.description,
                difficulty = chapter.difficulty,
                estimatedTimeMinutes = chapter.estimated_time_minutes,
                topicCount = topicCount
            )
        }
    }

    /**
     * Get a single expense tracker chapter with full details
     */
    suspend fun getExpenseTrackerChapter(chapterNumber: Int): ExpenseTrackerChapterDetailDto? = withTracing {
        logger.info("Fetching expense tracker chapter: {}", chapterNumber)

        val chapter = chapterRepo.findByChapterNumber(chapterNumber) ?: return@withTracing null

        // Get linked topics
        val topicLinks = topicChapterLinkRepo.findByChapterId(chapter.id!!).toList()
        val topicRefs = topicLinks.mapNotNull { link ->
            topicRepo.findById(link.topic_id)?.let { topic ->
                ExpenseTrackerTopicRefDto(
                    topicId = topic.id,
                    topicTitle = topic.title,
                    usageType = link.usage_type,
                    contextDescription = link.context_description
                )
            }
        }

        ExpenseTrackerChapterDetailDto(
            chapterNumber = chapter.chapter_number,
            title = chapter.title,
            description = chapter.description,
            introduction = chapter.introduction,
            implementationSteps = chapter.implementation_steps?.parseJsonArray(),
            codeSnippets = chapter.code_snippets?.parseCodeSnippets(),
            summary = chapter.summary,
            difficulty = chapter.difficulty,
            estimatedTimeMinutes = chapter.estimated_time_minutes,
            topics = topicRefs,
            navigation = ChapterNavigationDto(
                previous = chapter.previous_chapter,
                next = chapter.next_chapter
            )
        )
    }

    // =====================================================
    // Helper extension functions
    // =====================================================

    private fun KotlinContentTierEntity.toDto() = KotlinContentTierDto(
        tierLevel = tier_level,
        tierName = tier_name,
        title = title,
        explanation = explanation,
        codeExamples = code_examples?.parseJsonArray(),
        readingTimeMinutes = reading_time_minutes,
        learningObjectives = learning_objectives?.parseJsonArray(),
        prerequisites = prerequisites?.parseJsonArray()
    )

    private fun KotlinRunnableExampleEntity.toDto() = KotlinRunnableExampleDto(
        title = title,
        description = description,
        code = code,
        expectedOutput = expected_output,
        tierLevel = tier_level
    )

    // Simple JSON array parser (for string arrays stored as JSON)
    private fun String.parseJsonArray(): List<String> {
        return try {
            // Basic parsing for ["item1", "item2", ...] format
            this.trim()
                .removePrefix("[")
                .removeSuffix("]")
                .split(",")
                .map { it.trim().removeSurrounding("\"") }
                .filter { it.isNotBlank() }
        } catch (e: Exception) {
            logger.warn("Failed to parse JSON array: {}", this, e)
            emptyList()
        }
    }

    // Parse code snippets from JSON
    private fun String.parseCodeSnippets(): List<ExpenseTrackerCodeSnippetDto> {
        return try {
            // For now, return empty - proper JSON parsing would be added later
            emptyList()
        } catch (e: Exception) {
            logger.warn("Failed to parse code snippets: {}", this, e)
            emptyList()
        }
    }
}
