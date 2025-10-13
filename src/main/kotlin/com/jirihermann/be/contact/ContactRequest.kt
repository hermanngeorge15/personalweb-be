package com.jirihermann.be.contact

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class ContactRequest(
    @field:NotBlank @field:Size(max = 200)
    val name: String,
    @field:NotBlank @field:Email @field:Size(max = 320)
    val email: String,
    @field:NotBlank @field:Size(max = 4000)
    val message: String,
    val website: String? = null,
    // Add reCAPTCHA token field
    val recaptchaToken: String? = null
)