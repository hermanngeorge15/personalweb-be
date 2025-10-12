package com.jirihermann.be.resume

import com.jirihermann.be.resume.entity.ResumeCertificateEntity
import com.jirihermann.be.resume.entity.ResumeEducationEntity
import com.jirihermann.be.resume.entity.ResumeHobbiesEntity
import com.jirihermann.be.resume.entity.ResumeLanguageEntity
import com.jirihermann.be.resume.entity.ResumeProjectEntity
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import io.swagger.v3.oas.annotations.security.SecurityRequirement
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/resume")
@Tag(name = "Resume")
class ResumeController(private val service: ResumeService) {

  // Public
  @GetMapping("/projects")
  @Operation(summary = "List resume projects (public)")
  suspend fun listProjects(): List<ResumeProjectEntity> = service.listProjects()

  @GetMapping("/hobbies")
  @Operation(summary = "Get hobbies (public)")
  suspend fun getHobbies(): ResumeHobbiesEntity? = service.getHobbies()

  @GetMapping("/certificates")
  @Operation(summary = "List certificates (public)")
  suspend fun listCertificates(): List<ResumeCertificateEntity> = service.listCertificates()

  @GetMapping("/education")
  @Operation(summary = "List education (public)")
  suspend fun listEducation(): List<ResumeEducationEntity> = service.listEducation()

  // Admin
  @PostMapping("/projects")
  @Operation(summary = "Create resume project", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun createProject(@RequestBody req: ResumeService.ProjectUpsertRequest): UUID =
    service.createProject(req)

  @PutMapping("/projects/{id}")
  @Operation(summary = "Update resume project", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun updateProject(@PathVariable id: UUID, @RequestBody req: ResumeService.ProjectUpsertRequest) =
    service.updateProject(id, req)

  @DeleteMapping("/projects/{id}")
  @Operation(summary = "Delete resume project", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun deleteProject(@PathVariable id: UUID) = service.deleteProject(id)

  @PutMapping("/hobbies")
  @Operation(summary = "Upsert hobbies", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun upsertHobbies(@RequestBody req: ResumeService.HobbiesUpsertRequest): UUID =
    service.upsertHobbies(req)

  @PostMapping("/certificates")
  @Operation(summary = "Create certificate", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun createCertificate(@RequestBody req: ResumeService.CertificateUpsertRequest): UUID =
    service.createCertificate(req)

  @PutMapping("/certificates/{id}")
  @Operation(summary = "Update certificate", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun updateCertificate(@PathVariable id: UUID, @RequestBody req: ResumeService.CertificateUpsertRequest) =
    service.updateCertificate(id, req)

  @DeleteMapping("/certificates/{id}")
  @Operation(summary = "Delete certificate", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun deleteCertificate(@PathVariable id: UUID) = service.deleteCertificate(id)

  @PostMapping("/education")
  @Operation(summary = "Create education", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun createEducation(@RequestBody req: ResumeService.EducationUpsertRequest): UUID =
    service.createEducation(req)

  @PutMapping("/education/{id}")
  @Operation(summary = "Update education", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun updateEducation(@PathVariable id: UUID, @RequestBody req: ResumeService.EducationUpsertRequest) =
    service.updateEducation(id, req)

  @DeleteMapping("/education/{id}")
  @Operation(summary = "Delete education", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun deleteEducation(@PathVariable id: UUID) = service.deleteEducation(id)

  // Languages with level
  @GetMapping("/languages")
  @Operation(summary = "List languages (public)")
  suspend fun listLanguages(): List<ResumeLanguageEntity> = service.listLanguages()

  @PostMapping("/languages")
  @Operation(summary = "Create language", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun createLanguage(@RequestBody req: ResumeService.LanguageUpsertRequest): UUID =
    service.createLanguage(req)

  @PutMapping("/languages/{id}")
  @Operation(summary = "Update language", security = [SecurityRequirement(name = "bearer-jwt")])
  suspend fun updateLanguage(@PathVariable id: UUID, @RequestBody req: ResumeService.LanguageUpsertRequest) =
    service.updateLanguage(id, req)

  @DeleteMapping("/languages/{id}")
  @Operation(summary = "Delete language", security = [SecurityRequirement(name = "bearer-jwt")])
  @ResponseStatus(HttpStatus.NO_CONTENT)
  suspend fun deleteLanguage(@PathVariable id: UUID) = service.deleteLanguage(id)
}
