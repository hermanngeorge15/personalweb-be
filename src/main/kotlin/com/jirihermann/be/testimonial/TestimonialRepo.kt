package com.jirihermann.be.testimonial

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface TestimonialRepo : CoroutineCrudRepository<TestimonialEntity, UUID> {
  @Query("""
    select * from testimonial
    order by "order" asc
  """)
  suspend fun listOrdered(): List<TestimonialEntity>
}


