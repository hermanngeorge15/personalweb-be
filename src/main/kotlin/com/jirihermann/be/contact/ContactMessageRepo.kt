package com.jirihermann.be.contact

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import java.util.UUID

interface ContactMessageRepo : CoroutineCrudRepository<ContactMessageEntity, UUID> {
  @Query("""select * from contact_message where handled = false""")
  suspend fun listUnHandled(): List<ContactMessageEntity>
}


