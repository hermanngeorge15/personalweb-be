package com.jirihermann.be.resume.repository

import com.jirihermann.be.resume.entity.ResumeLanguageEntity
import com.jirihermann.be.resume.entity.ResumeProjectEntity
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import org.springframework.stereotype.Repository
import java.util.UUID


@Repository
interface ResumeLanguageRepo : CoroutineCrudRepository<ResumeLanguageEntity, UUID>