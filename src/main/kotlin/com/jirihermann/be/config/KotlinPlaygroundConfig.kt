package com.jirihermann.be.config

import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties(KotlinPlaygroundProperties::class)
class KotlinPlaygroundConfig
