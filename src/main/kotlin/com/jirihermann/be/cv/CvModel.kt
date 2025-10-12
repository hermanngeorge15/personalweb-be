package com.jirihermann.be.cv

import java.time.Instant

data class CvLink(val label: String, val url: String)

data class CvLanguage(val name: String, val level: String)

data class CvExperience(
  val company: String,
  val role: String,
  val location: String?,
  val from: String,
  val to: String,
  val bullets: List<String>,
  val technologies: List<String> = emptyList(),
  val storage: List<String> = emptyList()
)

data class CvEducation(
  val school: String,
  val degree: String?,
  val from: String,
  val to: String?
)

data class CvProject(
  val name: String,
  val company: String,
  val description: String?,
  val bullets: List<String> = emptyList(),
  val technologies: List<String> = emptyList(),
  val repoUrl: String? = null,
  val demoUrl: String? = null,
  val from: String,
  val to: String?
)

data class CvCertification(
  val name: String,
  val issuer: String?,
  val from: String?,
  val to: String?,
  val url: String?,
  val id: String?,
  val description: String?
)

data class CvModel(
  val slug: String,
  val lang: String,
  val fullName: String,
  val title: String,
  val summary: String,
  val photoUrl: String?,
  val location: String?,
  val phone: String?,
  val email: String?,
  val links: List<CvLink> = emptyList(),
  val skills: List<String> = emptyList(),
  val projects: List<CvProject> = emptyList(),
  val experiences: List<CvExperience> = emptyList(),
  val education: List<CvEducation> = emptyList(),
  val certifications: List<CvCertification> = emptyList(),
  val languages: List<CvLanguage> = emptyList(),
  val lastUpdated: String
)

object CvLabels {
  private val en = mapOf(
    "summary" to "SUMMARY",
    "projects" to "PROJECTS",
    "work_experience" to "WORK EXPERIENCE",
    "skills" to "SKILLS",
    "certifications" to "CERTIFICATIONS",
    "languages" to "LANGUAGES",
    "education" to "EDUCATION",
    "last_updated" to "Last updated"
  )
  private val cz = mapOf(
    "summary" to "SHRNUTÍ",
    "projects" to "PROJEKTY",
    "work_experience" to "PRACOVNÍ ZKUŠENOSTI",
    "skills" to "DOVEDNOSTI",
    "certifications" to "CERTIFIKACE",
    "languages" to "JAZYKY",
    "education" to "VZDĚLÁNÍ",
    "last_updated" to "Naposledy aktualizováno"
  )

  fun forLang(lang: String): Map<String, String> = when (lang.lowercase()) {
    "cz", "cs" -> cz
    else -> en
  }
}


