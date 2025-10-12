package com.jirihermann.be.resume.repository

import com.jirihermann.be.resume.entity.ResumeCertificateEntity
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import org.springframework.stereotype.Repository
import java.util.UUID

@Repository
interface ResumeCertificateRepo : CoroutineCrudRepository<ResumeCertificateEntity, UUID>
