package com.jirihermann.be.project

import com.jirihermann.be.tracing.withTracing
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.UUID

data class ProjectDto(
  val slug: String,
  val title: String,
  val summary: String,
  val content_mdx: String,
  val links: String,
  val order: Int
)

@Service
class ProjectService(private val repo: ProjectRepo) {
  private val logger = LoggerFactory.getLogger(ProjectService::class.java)

  suspend fun list(): List<ProjectDto> = withTracing {
    logger.info("Listing projects")
    val projects = repo.listOrdered().map {
      ProjectDto(
        slug = it.slug,
        title = it.title,
        summary = it.summary,
        content_mdx = it.content_mdx,
        links = it.links,
        order = it.order
      )
    }
    logger.info("Listed {} projects", projects.size)
    projects
  }

  // Admin
  data class ProjectUpsertRequest(
    val slug: String,
    val title: String,
    val summary: String,
    val content_mdx: String,
    val links: String,
    val order: Int
  )

  suspend fun create(req: ProjectUpsertRequest): UUID = withTracing {
    logger.info("Creating project: slug={}, title={}", req.slug, req.title)
    val saved = repo.save(
      ProjectEntity(
        slug = req.slug,
        title = req.title,
        summary = req.summary,
        content_mdx = req.content_mdx,
        links = req.links,
        order = req.order
      )
    )
    logger.info("Project created: id={}, slug={}", saved.id, saved.slug)
    saved.id!!
  }

  suspend fun update(id: UUID, req: ProjectUpsertRequest): Unit = withTracing {
    logger.info("Updating project: id={}, slug={}", id, req.slug)
    val current = repo.findById(id)
    if (current == null) {
      logger.warn("Project not found for update: id={}", id)
      return@withTracing
    }
    repo.save(
      current.copy(
        slug = req.slug,
        title = req.title,
        summary = req.summary,
        content_mdx = req.content_mdx,
        links = req.links,
        order = req.order
      )
    )
    logger.info("Project updated: id={}, slug={}", id, req.slug)
  }

  suspend fun delete(id: UUID): Unit = withTracing {
    logger.info("Deleting project: id={}", id)
    repo.deleteById(id)
    logger.info("Project deleted: id={}", id)
  }
}
