package com.jirihermann.be

import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.containers.wait.strategy.Wait
import org.testcontainers.containers.wait.strategy.WaitAllStrategy
import java.time.Duration

/**
 * The Postgres container the database tests run against.
 *
 * PostgreSQLContainer's default wait strategy only watches the container log for "ready to
 * accept connections". With Docker in a VM (Colima/Lima on macOS) the mapped host port is
 * forwarded a moment later, so a test that connects immediately is refused. Waiting for the
 * mapped port as well makes the container count as started only once the test can reach it.
 */
fun postgresContainer(): PostgreSQLContainer<Nothing> =
  PostgreSQLContainer<Nothing>("postgres:16-alpine").apply {
    withDatabaseName("personal")
    withUsername("personal")
    withPassword("personal")
    waitingFor(
      WaitAllStrategy()
        .withStrategy(Wait.forLogMessage(".*database system is ready to accept connections.*\\s", 2))
        .withStrategy(Wait.forListeningPort())
        .withStartupTimeout(Duration.ofSeconds(60)),
    )
  }
