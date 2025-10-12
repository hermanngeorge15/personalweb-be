package com.jirihermann.be.cv

import com.fasterxml.jackson.databind.ObjectMapper
import com.jirihermann.be.meta.MetaService
import com.jirihermann.be.resume.ResumeService
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder
import org.springframework.stereotype.Component
import org.thymeleaf.TemplateEngine
import org.thymeleaf.context.Context
import java.io.ByteArrayOutputStream

@Component
class PdfRenderer(
  private val templateEngine: TemplateEngine,
  private val resumeService: ResumeService,
  private val metaService: MetaService,
  private val objectMapper: ObjectMapper
) {

  suspend fun renderCv(cv: CvModel, labels: Map<String, String>): ByteArray {
    val html = renderHtml(cv, labels)
    val out = ByteArrayOutputStream()
    
    // Use resources directory as base URL for loading images and other assets
    val baseUrl = this::class.java.getResource("/static/")?.toString() 
      ?: this::class.java.getResource("/")?.toString()
    
    val builder = PdfRendererBuilder()
      // Render with full quality (HTML already has UTF-8 charset meta tag)
      .withHtmlContent(html, baseUrl)
      .toStream(out)
      // Add Roboto fonts for Czech character support
      .useFont({ this::class.java.getResourceAsStream("/fonts/Roboto-Regular.ttf") }, "Roboto")
      .useFont({ this::class.java.getResourceAsStream("/fonts/Roboto-Bold.ttf") }, "Roboto")
      .useFont({ this::class.java.getResourceAsStream("/fonts/Roboto-Italic.ttf") }, "Roboto")
      .useFont({ this::class.java.getResourceAsStream("/fonts/Roboto-Medium.ttf") }, "Roboto")

    builder.run()
    return out.toByteArray()
  }

  private suspend fun renderHtml(cv: CvModel, labels: Map<String, String>): String {
    // Fetch resume domain data
    val projects = resumeService.listProjects()
    val education = resumeService.listEducation()
    val certificates = resumeService.listCertificates()
    val languages = resumeService.listLanguages()
    val hobbies = resumeService.getHobbies()
    val meta = metaService.get()

    // Parse socials json (may be empty)
    val socials: Map<String, Any?> = try {
      meta?.socials?.let { objectMapper.readValue(it, Map::class.java) as Map<String, Any?> } ?: emptyMap()
    } catch (_: Exception) { emptyMap() }

    // Build a simple skills grouping (optional; safe defaults)
    val skills = mapOf(
      "languages" to languages.map { it.name },
      "frameworks" to emptyList<String>(),
      "datastores" to emptyList<String>(),
      "tools" to projects.flatMap { it.techStack }.distinct()
    )

    val resumeHeader = mapOf(
      "fullName" to cv.fullName,
      "role" to cv.title,
      "summary" to cv.summary,
      "email" to (cv.email ?: meta?.email),
      "location" to (cv.location ?: meta?.location),
      "phone" to cv.phone
    )

    val ctx = Context().apply {
      // Backward compatibility for older templates
      setVariable("cv", cv)
      setVariable("t", labels)

      // New canvas variables
      setVariable("resume", resumeHeader)
      setVariable("skills", skills)
      setVariable("projects", projects)
      setVariable("experiences", emptyList<Any>())
      setVariable("education", education)
      setVariable("certificates", certificates)
      setVariable("languages", languages)
      setVariable("hobbies", hobbies)
      setVariable("socials", socials)
    }
    // Use resume template with timeline layout and inline CSS for PDF rendering
    return templateEngine.process("cv/canvas/resume", ctx)
  }
}


