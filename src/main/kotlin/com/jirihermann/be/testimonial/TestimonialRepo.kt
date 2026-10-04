package com.jirihermann.be.testimonial

import org.springframework.data.r2dbc.repository.Modifying
import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface TestimonialRepo : CoroutineCrudRepository<TestimonialEntity, UUID> {
  @Query("""
    select * from testimonial
    order by "order" asc
  """)
  suspend fun listOrdered(): List<TestimonialEntity>

  // `order` is a reserved word in SQL and the generated INSERT/UPDATE of `save()` leaves it
  // unquoted, which Postgres rejects. Writes therefore go through these explicit statements.
  @Query("""
    insert into testimonial (author, role, avatar_url, quote, "order")
    values (:author, :role, :avatarUrl, :quote, :order)
    returning id
  """)
  suspend fun insert(author: String, role: String, avatarUrl: String?, quote: String, order: Int): UUID

  @Modifying
  @Query("""
    update testimonial
    set author = :author, role = :role, avatar_url = :avatarUrl, quote = :quote, "order" = :order
    where id = :id
  """)
  suspend fun update(id: UUID, author: String, role: String, avatarUrl: String?, quote: String, order: Int): Int
}


