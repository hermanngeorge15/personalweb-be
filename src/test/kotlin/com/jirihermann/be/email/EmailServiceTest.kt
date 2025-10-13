package com.jirihermann.be.email

import com.jirihermann.be.config.AwsSesProperties
import com.jirihermann.be.config.EmailProperties
import io.mockk.*
import junit.framework.TestCase.assertFalse
import junit.framework.TestCase.assertTrue
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import software.amazon.awssdk.services.ses.SesClient
import software.amazon.awssdk.services.ses.model.SendEmailRequest
import software.amazon.awssdk.services.ses.model.SendEmailResponse
import software.amazon.awssdk.services.ses.model.SesException

class EmailServiceTest {

  private lateinit var sesClient: SesClient
  private lateinit var awsSesProperties: AwsSesProperties
  private lateinit var emailProperties: EmailProperties
  private lateinit var emailService: EmailService

  @BeforeEach
  fun setup() {
    sesClient = mockk()
    awsSesProperties = AwsSesProperties(
      region = "us-east-1",
      fromEmail = "noreply@example.com",
      fromName = "Test Blog",
      enabled = true
    )
    emailProperties = EmailProperties(
      adminEmail = "admin@example.com",
      contactSubject = "Test Contact Subject"
    )
    emailService = EmailService(sesClient, awsSesProperties, emailProperties)
  }

  @AfterEach
  fun tearDown() {
    clearAllMocks()
  }

  @Test
  fun `sendEmail should send successfully with text body`() = runTest {
    // Given
    val request = EmailRequest(
      to = "recipient@example.com",
      subject = "Test Subject",
      body = "Test message body"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "message-id-123"
    }
    
    every { sesClient.sendEmail(any<SendEmailRequest>()) } returns response

    // When
    val result = emailService.sendEmail(request)

    // Then
    assertTrue(result)
    verify(exactly = 1) { sesClient.sendEmail(any<SendEmailRequest>()) }
  }

  @Test
  fun `sendEmail should send successfully with HTML body`() = runTest {
    // Given
    val request = EmailRequest(
      to = "recipient@example.com",
      subject = "Test Subject",
      body = "Test plain text",
      htmlBody = "<html><body><h1>Test HTML</h1></body></html>"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "message-id-456"
    }
    
    every { sesClient.sendEmail(any<SendEmailRequest>()) } returns response

    // When
    val result = emailService.sendEmail(request)

    // Then
    assertTrue(result)
    verify(exactly = 1) { sesClient.sendEmail(any<SendEmailRequest>()) }
  }

  @Test
  fun `sendEmail should include reply-to when provided`() = runTest {
    // Given
    val request = EmailRequest(
      to = "recipient@example.com",
      subject = "Test Subject",
      body = "Test message",
      replyTo = "sender@example.com"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "message-id-789"
    }
    
    every { sesClient.sendEmail(any<SendEmailRequest>()) } returns response

    // When
    val result = emailService.sendEmail(request)

    // Then
    assertTrue(result)
    verify(exactly = 1) { 
      sesClient.sendEmail(match<SendEmailRequest> { 
        it.replyToAddresses().contains("sender@example.com")
      }) 
    }
  }

  @Test
  fun `sendEmail should return false when SES is disabled`() = runTest {
    // Given
    val disabledProperties = awsSesProperties.copy(enabled = false)
    val disabledService = EmailService(null, disabledProperties, emailProperties)
    
    val request = EmailRequest(
      to = "recipient@example.com",
      subject = "Test Subject",
      body = "Test message"
    )

    // When
    val result = disabledService.sendEmail(request)

    // Then
    assertFalse(result)
  }

  @Test
  fun `sendEmail should return false on SES exception`() = runTest {
    // Given
    val request = EmailRequest(
      to = "invalid@example.com",
      subject = "Test Subject",
      body = "Test message"
    )
    
    every { sesClient.sendEmail(any<SendEmailRequest>()) } throws 
      SesException.builder().message("Email address not verified").build()

    // When
    val result = emailService.sendEmail(request)

    // Then
    assertFalse(result)
    verify(exactly = 1) { sesClient.sendEmail(any<SendEmailRequest>()) }
  }

  @Test
  fun `sendContactFormNotification should send email to admin`() = runTest {
    // Given
    val data = ContactFormEmailData(
      name = "John Doe",
      email = "john@example.com",
      message = "Test contact message",
      timestamp = "2024-01-01 10:00:00 UTC"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "contact-message-id"
    }
    
    every { sesClient.sendEmail(any<SendEmailRequest>()) } returns response

    // When
    val result = emailService.sendContactFormNotification(data)

    // Then
    assertTrue(result)
    verify(exactly = 1) { 
      sesClient.sendEmail(match<SendEmailRequest> { 
        it.destination().toAddresses().contains("admin@example.com") &&
        it.replyToAddresses().contains("john@example.com")
      }) 
    }
  }

  @Test
  fun `HTML body should escape special characters`() = runTest {
    // Given
    val data = ContactFormEmailData(
      name = "Test <script>alert('xss')</script>",
      email = "test@example.com",
      message = "Message with <html> & \"quotes\" and 'apostrophes'",
      timestamp = "2024-01-01 10:00:00 UTC"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "xss-test-message-id"
    }
    
    var capturedHtml = ""
    every { sesClient.sendEmail(any<SendEmailRequest>()) } answers {
      val request = firstArg<SendEmailRequest>()
      capturedHtml = request.message().body().html().data()
      response
    }

    // When
    emailService.sendContactFormNotification(data)

    // Then
    assertTrue(capturedHtml.contains("&lt;script&gt;"))
    assertTrue(capturedHtml.contains("&lt;html&gt;"))
    assertTrue(capturedHtml.contains("&quot;quotes&quot;"))
    assertTrue(capturedHtml.contains("&#39;apostrophes&#39;"))
    assertTrue(capturedHtml.contains("&amp;"))
    assertFalse(capturedHtml.contains("<script>"))
  }

  @Test
  fun `text body should contain all contact form fields`() = runTest {
    // Given
    val data = ContactFormEmailData(
      name = "Jane Smith",
      email = "jane@example.com",
      message = "Hello, this is my message!",
      timestamp = "2024-01-01 12:00:00 UTC"
    )
    
    val response = mockk<SendEmailResponse> {
      every { messageId() } returns "text-body-test"
    }
    
    var capturedText = ""
    every { sesClient.sendEmail(any<SendEmailRequest>()) } answers {
      val request = firstArg<SendEmailRequest>()
      capturedText = request.message().body().text().data()
      response
    }

    // When
    emailService.sendContactFormNotification(data)

    // Then
    assertTrue(capturedText.contains("Jane Smith"))
    assertTrue(capturedText.contains("jane@example.com"))
    assertTrue(capturedText.contains("Hello, this is my message!"))
    assertTrue(capturedText.contains("2024-01-01 12:00:00 UTC"))
  }

  @Test
  fun `service should not throw exception when SES client is null`() = runTest {
    // Given
    val nullClientService = EmailService(null, awsSesProperties, emailProperties)
    val request = EmailRequest(
      to = "test@example.com",
      subject = "Test",
      body = "Test"
    )

    // When & Then
    assertDoesNotThrow {
      val result = nullClientService.sendEmail(request)
      assertFalse(result)
    }
  }
}

