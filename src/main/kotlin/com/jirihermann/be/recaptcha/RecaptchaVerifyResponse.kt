package com.jirihermann.be.recaptcha

data class RecaptchaVerifyResponse(
    val success: Boolean,
    val score: Double? = null,
    val action: String? = null,
    val challengeTs: String? = null,
    val hostname: String? = null,
    val errorCodes: List<String>? = null
)