package com.jirihermann.be.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.bind.ConstructorBinding

@ConfigurationProperties(prefix = "aws.ses")
data class AwsSesProperties(
    val region: String = "us-east-1",
    val fromEmail: String = "",
    val fromName: String = "Blog Notification",
    val enabled: Boolean = true,
    val accessKeyId: String? = null,
    val secretAccessKey: String? = null
)
