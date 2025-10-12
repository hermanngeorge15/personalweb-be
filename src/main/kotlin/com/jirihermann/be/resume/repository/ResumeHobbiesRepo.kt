package com.jirihermann.be.resume.repository

import com.jirihermann.be.resume.entity.ResumeHobbiesEntity
import com.jirihermann.be.resume.entity.ResumeProjectEntity
import org.springframework.data.repository.kotlin.CoroutineCrudRepository
import org.springframework.stereotype.Repository
import java.util.UUID


@Repository
interface ResumeHobbiesRepo : CoroutineCrudRepository<ResumeHobbiesEntity, UUID>
