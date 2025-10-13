package com.jirihermann.be.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "email")
data class EmailProperties(
    val adminEmail: String = "",
    val contactSubject: String = "New Contact Form Submission"
)
