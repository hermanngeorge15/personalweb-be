package com.jirihermann.be.resume.entity

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.LocalDate
import java.util.UUID

@Table("resume_hobbies")
data class ResumeHobbiesEntity(
    @Id val id: UUID? = null,
    val sports: List<String> = emptyList(),
    val others: List<String> = emptyList()
)

