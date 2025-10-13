package com.jirihermann.be.config

import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties(RecaptchaProperties::class)
class CaptchaConfig {
}