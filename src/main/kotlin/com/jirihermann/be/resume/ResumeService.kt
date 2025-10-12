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
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.toList
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
  suspend fun listProjects(): List<ResumeProjectEntity> = projectRepo.findAll().toList()
  suspend fun createProject(req: ProjectUpsertRequest): UUID =
    projectRepo.save(
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
    ).id!!
  suspend fun updateProject(id: UUID, req: ProjectUpsertRequest) {
    val current = projectRepo.findById(id) ?: return
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
  }
  suspend fun deleteProject(id: UUID) = projectRepo.deleteById(id)

  // Hobbies (single record)
  suspend fun getHobbies(): ResumeHobbiesEntity? = hobbiesRepo.findAll().firstOrNull()
  suspend fun upsertHobbies(req: HobbiesUpsertRequest): UUID {
    val current = getHobbies()
    val saved = if (current == null) {
      hobbiesRepo.save(ResumeHobbiesEntity(sports = req.sports, others = req.others))
    } else {
      hobbiesRepo.save(current.copy(sports = req.sports, others = req.others))
    }
    return saved.id!!
  }

  // Certificates
  suspend fun listCertificates(): List<ResumeCertificateEntity> = certificateRepo.findAll().toList()
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
  suspend fun listEducation(): List<ResumeEducationEntity> = educationRepo.findAll().toList()
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

  suspend fun listLanguages(): List<ResumeLanguageEntity> = languageRepo.findAll().toList()

  suspend fun createLanguage(req: LanguageUpsertRequest): UUID =
    languageRepo.save(ResumeLanguageEntity(name = req.name, level = req.level)).id!!

  suspend fun updateLanguage(id: UUID, req: LanguageUpsertRequest) {
    val current = languageRepo.findById(id) ?: return
    languageRepo.save(current.copy(name = req.name, level = req.level))
  }

  suspend fun deleteLanguage(id: UUID) = languageRepo.deleteById(id)

}