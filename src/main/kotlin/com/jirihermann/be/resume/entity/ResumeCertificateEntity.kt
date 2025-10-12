package com.jirihermann.be.resume.entity

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Column
import org.springframework.data.relational.core.mapping.Table
import java.time.Instant
import java.util.UUID

@Table("resume_certificate")
data class ResumeCertificateEntity(
    @Id val id: UUID? = null,
    val name: String,
    val issuer: String? = null,
    @Column("start_at") val startAt: Instant? = null,
    @Column("end_at") val endAt: Instant? = null,
    val description: String? = null,
    @Column("certificate_id") val certificateId: String? = null,
    val url: String? = null
)