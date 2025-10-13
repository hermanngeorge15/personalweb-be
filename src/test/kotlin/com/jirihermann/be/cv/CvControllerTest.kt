package com.jirihermann.be.cv

import io.mockk.coEvery
import io.mockk.mockk
import org.junit.jupiter.api.Test
import org.springframework.http.MediaType
import org.springframework.test.web.reactive.server.WebTestClient

class CvControllerTest {
  private val assembler: CvAssembler = mockk()
  private val renderer: PdfRenderer = mockk()
  private val client = WebTestClient.bindToController(CvController(assembler, renderer)).build()

  @Test
  fun pdf_ok() {
    val cv = CvModel(
      slug = "jiri",
      lang = "en",
      fullName = "Jiri Hermann",
      title = "Senior Kotlin Engineer",
      summary = "",
      photoUrl = null,
      location = null,
      phone = null,
      email = null,
      links = emptyList(),
      skills = emptyList(),
      experiences = emptyList(),
      education = emptyList(),
      languages = emptyList(),
      lastUpdated = "2025-01-01"
    )
    coEvery { assembler.assemble("jiri", "en") } returns cv
    coEvery { renderer.renderCv(cv, any()) } returns byteArrayOf(1, 2, 3)

    client.get().uri("/api/cv/jiri.en.pdf")
      .exchange()
      .expectStatus().isOk
      .expectHeader().contentType(MediaType.APPLICATION_PDF)
      .expectBody()
      .consumeWith { resp ->
        assert((resp.responseBody?.size ?: 0) > 0)
      }
  }
}


