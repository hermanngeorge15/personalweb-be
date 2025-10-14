package com.jirihermann.be.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "recaptcha")
data class RecaptchaProperties(
    val enabled: Boolean = true,
    val secret: String = "",
    val verifyUrl: String = "https://www.google.com/recaptcha/api/siteverify",
    val minimumScore: Double = 0.5,
    val expectedAction: String = "submit",
    val expectedHostname: String = ""
)
