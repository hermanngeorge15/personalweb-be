package com.jirihermann.be.recaptcha

data class RecaptchaVerifyRequest(
    val secret: String,
    val response: String,
    val remoteip: String? = null
)
