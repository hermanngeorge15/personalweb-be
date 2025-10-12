package com.jirihermann.be.resume.entity

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.LocalDate
import java.util.UUID

@Table("resume_language")
data class ResumeLanguageEntity(
    @Id val id: UUID? = null,
    val name: String,
    val level: String // např. "B2", "C1", "Native", "Professional"
)