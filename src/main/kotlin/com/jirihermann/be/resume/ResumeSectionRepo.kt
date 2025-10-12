package com.jirihermann.be.resume

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface ResumeSectionRepo : CoroutineCrudRepository<ResumeSectionEntity, UUID> {
  @Query("""
    select * from resume_section
    order by "order" asc
  """)
  suspend fun listOrdered(): List<ResumeSectionEntity>
}


