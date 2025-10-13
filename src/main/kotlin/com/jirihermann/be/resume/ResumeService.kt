package com.jirihermann.be.resume

import com.jirihermann.be.resume.entity.ResumeCertificateEntity
import com.jirihermann.be.resume.entity.ResumeEducationEntity
import com.jirihermann.be.resume.entity.ResumeHobbiesEntity
import com.jirihermann.be.resume.entity.ResumeLanguageEntity
import com.jirihermann.be.resume.entity.ResumeProjectEntity
import com.jirihermann.be.resume.repository.ResumeCertificateRepo
import com.jirihermann.be.resume.repository.ResumeEducationRepo
import com.jirihermann.be.resume.repository.ResumeHobbiesRepo
import com.jirihermann.be.resume.repository.ResumeLanguageRepo
import com.jirihermann.be.resume.repository.ResumeProjectRepo
import com.jirihermann.be.tracing.withTracing
import com.jirihermann.be.tracing.withChildSpan
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.toList
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.time.Instant
import java.util.UUID


@Service
class ResumeService(
  private val projectRepo: ResumeProjectRepo,
  private val hobbiesRepo: ResumeHobbiesRepo,
  private val certificateRepo: ResumeCertificateRepo,
  private val educationRepo: ResumeEducationRepo,
  private val languageRepo: ResumeLanguageRepo
) {
  private val logger = LoggerFactory.getLogger(ResumeService::class.java)
  // DTOs
  data class ProjectUpsertRequest(
    val company: String,
    val projectName: String,
    val from: Instant,
    val until: Instant?,
    val description: String?,
    val responsibilities: List<String> = emptyList(),
    val techStack: List<String> = emptyList(),
    val repoUrl: String? = null,
    val demoUrl: String? = null
  )
  data class HobbiesUpsertRequest(
    val sports: List<String> = emptyList(),
    val others: List<String> = emptyList()
  )
  data class CertificateUpsertRequest(
    val name: String,
    val issuer: String?,
    val from: Instant?,
    val to: Instant?,
    val description: String?,
    val certificateId: String?,
    val url: String?
  )
  data class EducationUpsertRequest(
    val institution: String,
    val field: String?,
    val degree: String?,
    val since: Instant,
    val expectedUntil: Instant?,
    val thesisTitle: String?,
    val thesisDescription: String?,
    val status: String = "studying"
  )
  // Languages with level
  data class LanguageUpsertRequest(
    val name: String,
    val level: String // validate on FE/BE (A1..C2, Native, etc.)
  )


  // Projects
  suspend fun listProjects(): List<ResumeProjectEntity> = withTracing {
    logger.info("Listing resume projects")
    val projects = projectRepo.findAll().toList()
    logger.info("Listed {} resume projects", projects.size)
    projects
  }
  
  suspend fun createProject(req: ProjectUpsertRequest): UUID = withTracing {
    logger.info("Creating resume project: company={}, project={}", req.company, req.projectName)
    val saved = projectRepo.save(
      ResumeProjectEntity(
        company = req.company,
        projectName = req.projectName,
        startAt = req.from,
        endAt = req.until,
        description = req.description,
        responsibilities = req.responsibilities,
        techStack = req.techStack,
        repoUrl = req.repoUrl,
        demoUrl = req.demoUrl
      )
    )
    logger.info("Resume project created: id={}", saved.id)
    saved.id!!
  }
  
  suspend fun updateProject(id: UUID, req: ProjectUpsertRequest): Unit = withTracing {
    logger.info("Updating resume project: id={}", id)
    val current = projectRepo.findById(id)
    if (current == null) {
      logger.warn("Resume project not found for update: id={}", id)
      return@withTracing
    }
    projectRepo.save(
      current.copy(
        company = req.company,
        projectName = req.projectName,
        startAt = req.from,
        endAt = req.until,
        description = req.description,
        responsibilities = req.responsibilities,
        techStack = req.techStack,
        repoUrl = req.repoUrl,
        demoUrl = req.demoUrl
      )
    )
    logger.info("Resume project updated: id={}", id)
  }
  
  suspend fun deleteProject(id: UUID): Unit = withTracing {
    logger.info("Deleting resume project: id={}", id)
    projectRepo.deleteById(id)
    logger.info("Resume project deleted: id={}", id)
  }

  // Hobbies (single record)
  suspend fun getHobbies(): ResumeHobbiesEntity? = withTracing {
    logger.info("Fetching hobbies")
    hobbiesRepo.findAll().firstOrNull()
  }
  
  suspend fun upsertHobbies(req: HobbiesUpsertRequest): UUID = withTracing {
    logger.info("Upserting hobbies: sports={}, others={}", req.sports.size, req.others.size)
    val current = getHobbies()
    val saved = if (current == null) {
      logger.info("Creating new hobbies record")
      hobbiesRepo.save(ResumeHobbiesEntity(sports = req.sports, others = req.others))
    } else {
      logger.info("Updating existing hobbies record: id={}", current.id)
      hobbiesRepo.save(current.copy(sports = req.sports, others = req.others))
    }
    saved.id!!
  }

  // Certificates
  suspend fun listCertificates(): List<ResumeCertificateEntity> = withTracing {
    logger.info("Listing certificates")
    val certificates = certificateRepo.findAll().toList()
    logger.info("Listed {} certificates", certificates.size)
    certificates
  }
  suspend fun createCertificate(req: CertificateUpsertRequest): UUID =
    certificateRepo.save(
      ResumeCertificateEntity(
        name = req.name,
        issuer = req.issuer,
        startAt = req.from,
        endAt = req.to,
        description = req.description,
        certificateId = req.certificateId,
        url = req.url
      )
    ).id!!
  suspend fun updateCertificate(id: UUID, req: CertificateUpsertRequest) {
    val current = certificateRepo.findById(id) ?: return
    certificateRepo.save(
      current.copy(
        name = req.name,
        issuer = req.issuer,
        startAt = req.from,
        endAt = req.to,
        description = req.description,
        certificateId = req.certificateId,
        url = req.url
      )
    )
  }
  suspend fun deleteCertificate(id: UUID) = certificateRepo.deleteById(id)

  // Education
  suspend fun listEducation(): List<ResumeEducationEntity> = withTracing {
    logger.info("Listing education")
    val education = educationRepo.findAll().toList()
    logger.info("Listed {} education entries", education.size)
    education
  }
  suspend fun createEducation(req: EducationUpsertRequest): UUID =
    educationRepo.save(
      ResumeEducationEntity(
        institution = req.institution,
        field = req.field,
        degree = req.degree,
        since = req.since,
        expectedUntil = req.expectedUntil,
        thesisTitle = req.thesisTitle,
        thesisDescription = req.thesisDescription,
        status = req.status
      )
    ).id!!
  suspend fun updateEducation(id: UUID, req: EducationUpsertRequest) {
    val current = educationRepo.findById(id) ?: return
    educationRepo.save(
      current.copy(
        institution = req.institution,
        field = req.field,
        degree = req.degree,
        since = req.since,
        expectedUntil = req.expectedUntil,
        thesisTitle = req.thesisTitle,
        thesisDescription = req.thesisDescription,
        status = req.status
      )
    )
  }
  suspend fun deleteEducation(id: UUID) = educationRepo.deleteById(id)

  suspend fun listLanguages(): List<ResumeLanguageEntity> = withTracing {
    logger.info("Listing languages")
    val languages = languageRepo.findAll().toList()
    logger.info("Listed {} languages", languages.size)
    languages
  }

  suspend fun createLanguage(req: LanguageUpsertRequest): UUID = withTracing {
    logger.info("Creating language: name={}, level={}", req.name, req.level)
    val saved = languageRepo.save(ResumeLanguageEntity(name = req.name, level = req.level))
    logger.info("Language created: id={}", saved.id)
    saved.id!!
  }

  suspend fun updateLanguage(id: UUID, req: LanguageUpsertRequest): Unit = withTracing {
    logger.info("Updating language: id={}", id)
    val current = languageRepo.findById(id)
    if (current == null) {
      logger.warn("Language not found for update: id={}", id)
      return@withTracing
    }
    languageRepo.save(current.copy(name = req.name, level = req.level))
    logger.info("Language updated: id={}", id)
  }

  suspend fun deleteLanguage(id: UUID): Unit = withTracing {
    logger.info("Deleting language: id={}", id)
    languageRepo.deleteById(id)
    logger.info("Language deleted: id={}", id)
  }

}