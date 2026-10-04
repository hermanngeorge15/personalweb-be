package com.jirihermann.be.project

import org.springframework.data.r2dbc.repository.Modifying
import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface ProjectRepo : CoroutineCrudRepository<ProjectEntity, UUID> {
  @Query("""
    select * from project
    order by "order" asc
  """)
  suspend fun listOrdered(): List<ProjectEntity>

  // `order` is a reserved word in SQL and the generated INSERT/UPDATE of `save()` leaves it
  // unquoted, which Postgres rejects. Writes therefore go through these explicit statements.
  @Query("""
    insert into project (slug, title, summary, content_mdx, links, "order")
    values (:slug, :title, :summary, :contentMdx, cast(:links as jsonb), :order)
    returning id
  """)
  suspend fun insert(slug: String, title: String, summary: String, contentMdx: String, links: String, order: Int): UUID

  @Modifying
  @Query("""
    update project
    set slug = :slug, title = :title, summary = :summary, content_mdx = :contentMdx,
        links = cast(:links as jsonb), "order" = :order
    where id = :id
  """)
  suspend fun update(id: UUID, slug: String, title: String, summary: String, contentMdx: String, links: String, order: Int): Int
}


