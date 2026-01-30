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
    private val dependencyRepo: KotlinTopicDependencyRepo
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
}
