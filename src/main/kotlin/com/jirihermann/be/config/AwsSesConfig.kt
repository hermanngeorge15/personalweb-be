package com.jirihermann.be.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.context.properties.bind.ConstructorBinding
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.ses.SesClient



@Configuration
@EnableConfigurationProperties(AwsSesProperties::class, EmailProperties::class)
class AwsSesConfig(
    private val properties: AwsSesProperties,
) {

  @Bean
  fun sesClient(): SesClient? {
    if (!properties.enabled) {
      return null
    }

    val credentialsProvider: AwsCredentialsProvider = if (
      !properties.accessKeyId.isNullOrBlank() && !properties.secretAccessKey.isNullOrBlank()
    ) {
      logger.debug("Using provided access keys for AWS SES")
      // Use provided access keys
      StaticCredentialsProvider.create(
        AwsBasicCredentials.create(properties.accessKeyId, properties.secretAccessKey)
      )
    } else {
      // Use default credentials chain (IAM role, env vars, etc.)
      DefaultCredentialsProvider.create()
    }

    return SesClient.builder()
      .region(Region.of(properties.region))
      .credentialsProvider(credentialsProvider)
      .build()
  }

  companion object {
    private val logger = org.slf4j.LoggerFactory.getLogger(AwsSesConfig::class.java)
  }
}

