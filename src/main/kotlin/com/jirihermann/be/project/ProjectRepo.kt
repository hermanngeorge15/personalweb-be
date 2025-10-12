package com.jirihermann.be.project

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface ProjectRepo : CoroutineCrudRepository<ProjectEntity, UUID> {
  @Query("""
    select * from project
    order by "order" asc
  """)
  suspend fun listOrdered(): List<ProjectEntity>
}


