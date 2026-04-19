package com.jirihermann.be.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "kotlin-playground")
data class KotlinPlaygroundProperties(
    val enabled: Boolean = true,
    val serverUrl: String = "https://api.kotlinlang.org",
    val compilerUrl: String = "https://api.kotlinlang.org/api/2.0.21/compiler/run",
    val timeout: Int = 30000
)
