package com.jirihermann.be.media

import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties(MediaProperties::class)
class MediaConfig
