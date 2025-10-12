package com.jirihermann.be.resume.entity

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("resume_project")
data class ResumeProjectEntity(
    @Id val id: UUID? = null,
    val company: String,
    @Column("project_name") val projectName: String,
    @Column("start_at") val startAt: Instant,
    @Column("end_at") val endAt: Instant?,
    val description: String?,
    val responsibilities: List<String> = emptyList(),
    @Column("tech_stack") val techStack: List<String> = emptyList(),
    @Column("repo_url") val repoUrl: String? = null,
    @Column("demo_url") val demoUrl: String? = null
)
