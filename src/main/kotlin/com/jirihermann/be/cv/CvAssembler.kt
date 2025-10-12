package com.jirihermann.be.cv

import com.jirihermann.be.resume.ResumeService
import kotlinx.coroutines.flow.toList
import org.jsoup.Jsoup
import org.jsoup.safety.Safelist
import org.springframework.stereotype.Service
import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

@Service
class CvAssembler(
  private val resumeService: ResumeService
) {
  private val ymFormatter = DateTimeFormatter.ofPattern("yyyy-MM").withZone(ZoneOffset.UTC)
  private val yFormatter = DateTimeFormatter.ofPattern("yyyy").withZone(ZoneOffset.UTC)

  suspend fun assemble(slug: String, lang: String): CvModel {
    val projects = resumeService.listProjects()
    val certificates = resumeService.listCertificates()
    val languages = resumeService.listLanguages()
    val education = resumeService.listEducation()

    val experiences = projects
      .sortedWith(
        compareByDescending<com.jirihermann.be.resume.entity.ResumeProjectEntity> { it.endAt ?: java.time.Instant.MAX }
          .thenByDescending { it.startAt }
      )
      .map { p ->
        CvExperience(
          company = p.company,
          role = p.projectName,
          location = null,
          from = ymFormatter.format(p.startAt),
          to = p.endAt?.let { ymFormatter.format(it) } ?: "present",
          bullets = sanitizeLines(p.responsibilities),
          technologies = p.techStack
        )
      }

    val projectsCv = projects
      .sortedWith(
        compareByDescending<com.jirihermann.be.resume.entity.ResumeProjectEntity> { it.endAt ?: java.time.Instant.MAX }
          .thenByDescending { it.startAt }
      )
      .map { p ->
        CvProject(
          name = p.projectName,
          company = p.company,
          description = sanitize(p.description),
          bullets = sanitizeLines(p.responsibilities),
          technologies = p.techStack,
          repoUrl = p.repoUrl,
          demoUrl = p.demoUrl,
          from = ymFormatter.format(p.startAt),
          to = p.endAt?.let { ymFormatter.format(it) }
        )
      }

    val edu = education.sortedByDescending { it.since }
      .map { e ->
        CvEducation(
          school = e.institution,
          degree = listOfNotNull(e.degree, e.field).joinToString(", ").ifBlank { null },
          from = e.since.let { yFormatter.format(it) },
          to = e.expectedUntil?.let { yFormatter.format(it) }
        )
      }

    val langs = languages.map { CvLanguage(it.name, it.level) }

    val certs = certificates
      .sortedWith(
        compareByDescending<com.jirihermann.be.resume.entity.ResumeCertificateEntity> { it.endAt ?: it.startAt ?: java.time.Instant.MIN }
      )
      .map { c ->
        CvCertification(
          name = c.name,
          issuer = c.issuer,
          from = c.startAt?.let { yFormatter.format(it) },
          to = c.endAt?.let { yFormatter.format(it) },
          url = c.url,
          id = c.certificateId,
          description = sanitize(c.description)
        )
      }

    // TODO replace with profile table later; for now provide minimal demo data
    val fullName = "Ing. Jiri Hermann"
    val title = "Software Engineer"
    val summary = """
      I'm Jiří Hermann — a Backend Software Engineer and Community Builder based in Prague. I focus on designing clean, reliable, and scalable backend systems using Kotlin, coroutines, and Spring WebFlux, with hands-on experience in PostgreSQL, Redis, Kafka, and Docker.
      
      As the founder of Kotlin Server Squad, I build a space for developers passionate about Kotlin, Java, and the JVM to connect, learn, and grow together.
    """.trimIndent()
    val skills = listOf("Kotlin", "Spring Boot", "WebFlux", "PostgreSQL", "Docker", "Kubernetes")
    val links = listOf(
      CvLink("GitHub (Personal)", "https://github.com/hermanngeorge15"),
      CvLink("GitHub (Kotlin Server Squad)", "https://github.com/Kotlin-server-squad"),
      CvLink("Website", "https://jirihermann.com/"),
      CvLink("KSS Website", "https://kotlinserversquad.com")
    )

    return CvModel(
      slug = slug,
      lang = lang,
      fullName = fullName,
      title = title,
      summary = sanitize(summary),
      photoUrl = null,
      location = "Prague, Czechia",
      phone = "+420 774246408",
      email = "me@jirihermann.com",
      links = links,
      skills = skills,
      projects = projectsCv,
      experiences = experiences,
      education = edu,
      certifications = certs,
      languages = langs,
      lastUpdated = DateTimeFormatter.ISO_LOCAL_DATE.withZone(ZoneOffset.UTC).format(Instant.now())
    )
  }

  private fun sanitize(html: String?): String = if (html.isNullOrBlank()) "" else Jsoup.clean(html, Safelist.none())

  private fun sanitizeLines(lines: List<String>?): List<String> =
    (lines ?: emptyList()).map { sanitize(it) }.filter { it.isNotBlank() }
}


