package com.jirihermann.be

import org.flywaydb.core.Flyway
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInstance
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.sql.DriverManager

@Testcontainers
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class IntegrationFlywayTest {
  companion object {
    @Container
    @JvmStatic
    val postgres = postgresContainer().apply { start() }
  }

  @Test
  fun `migrations apply successfully`() {
    val jdbcUrl = postgres.jdbcUrl
    val flyway = Flyway.configure()
      .dataSource(jdbcUrl, postgres.username, postgres.password)
      .locations("classpath:db/migration")
      .placeholderReplacement(false)
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


