package com.jirihermann.be

import org.flywaydb.core.Flyway
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInstance
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.sql.DriverManager

@Testcontainers
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class IntegrationFlywayTest {
  companion object {
    @Container
    @JvmStatic
    val postgres = PostgreSQLContainer<Nothing>("postgres:16-alpine").apply {
      withDatabaseName("personal")
      withUsername("personal")
      withPassword("personal")
      start()
    }
  }

  @Test
  fun `migrations apply successfully`() {
    val jdbcUrl = postgres.jdbcUrl
    val flyway = Flyway.configure()
      .dataSource(jdbcUrl, postgres.username, postgres.password)
      .locations("classpath:db/migration")
      .load()
    flyway.migrate()

    DriverManager.getConnection(jdbcUrl, postgres.username, postgres.password).use { conn ->
      conn.createStatement().use { st ->
        st.executeQuery("select to_regclass('public.post') is not null").use { rs ->
          rs.next()
          assertTrue(rs.getBoolean(1))
        }
      }
    }
  }
}


