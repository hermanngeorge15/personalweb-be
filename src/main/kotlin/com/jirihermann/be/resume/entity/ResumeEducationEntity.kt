package com.jirihermann.be.resume.entity

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

@Table("resume_education")
data class ResumeEducationEntity(
    @Id val id: UUID? = null,
    val institution: String,
    val field: String? = null,
    val degree: String? = null,
    val since: Instant,
    @Column("expected_until") val expectedUntil: Instant? = null,
    @Column("thesis_title") val thesisTitle: String? = null,
    @Column("thesis_description") val thesisDescription: String? = null,
    val status: String = "studying"
)