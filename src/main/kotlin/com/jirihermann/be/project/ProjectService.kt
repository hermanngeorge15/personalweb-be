package com.jirihermann.be.project

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
  suspend fun list(): List<ProjectDto> = repo.listOrdered().map {
    ProjectDto(
      slug = it.slug,
      title = it.title,
      summary = it.summary,
      content_mdx = it.content_mdx,
      links = it.links,
      order = it.order
    )
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

  suspend fun create(req: ProjectUpsertRequest): UUID {
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
    return saved.id!!
  }

  suspend fun update(id: UUID, req: ProjectUpsertRequest) {
    val current = repo.findById(id) ?: return
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
  }

  suspend fun delete(id: UUID) {
    repo.deleteById(id)
  }
}
