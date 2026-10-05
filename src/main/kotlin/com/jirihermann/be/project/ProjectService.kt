package com.jirihermann.be.project

import com.jirihermann.be.tracing.withTracing
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.UUID

data class ProjectDto(
  val id: UUID?,
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
        id = it.id,
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
    val links: String = "{}",
    val order: Int = 0
  )

  suspend fun create(req: ProjectUpsertRequest): UUID = withTracing {
    logger.info("Creating project: slug={}, title={}", req.slug, req.title)
    val id = repo.insert(req.slug, req.title, req.summary, req.content_mdx, req.links, req.order)
    logger.info("Project created: id={}, slug={}", id, req.slug)
    id
  }

  /** Replaces the project with [id]. Returns false when no such project exists. */
  suspend fun update(id: UUID, req: ProjectUpsertRequest): Boolean = withTracing {
    logger.info("Updating project: id={}, slug={}", id, req.slug)
    val updated = repo.update(id, req.slug, req.title, req.summary, req.content_mdx, req.links, req.order) > 0
    if (!updated) logger.warn("Project not found for update: id={}", id)
    updated
  }

  suspend fun delete(id: UUID): Unit = withTracing {
    logger.info("Deleting project: id={}", id)
    repo.deleteById(id)
    logger.info("Project deleted: id={}", id)
  }
}
