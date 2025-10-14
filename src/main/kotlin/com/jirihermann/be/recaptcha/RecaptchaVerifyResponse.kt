package com.jirihermann.be.recaptcha

import com.fasterxml.jackson.annotation.JsonProperty

data class RecaptchaVerifyResponse(
    val success: Boolean = false,
    val score: Double? = null,
    val action: String? = null,
    @JsonProperty("challenge_ts")
    val challengeTs: String? = null,
    val hostname: String? = null,
    @JsonProperty("error-codes")
    val errorCodes: List<String>? = null
)