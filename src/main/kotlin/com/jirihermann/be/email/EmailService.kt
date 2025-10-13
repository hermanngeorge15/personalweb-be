package com.jirihermann.be.email

import com.jirihermann.be.config.AwsSesProperties
import com.jirihermann.be.config.EmailProperties
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import software.amazon.awssdk.services.ses.SesClient
import software.amazon.awssdk.services.ses.model.*

@Service
class EmailService(
  private val sesClient: SesClient?,
  private val awsSesProperties: AwsSesProperties,
  private val emailProperties: EmailProperties
) {
  private val logger = LoggerFactory.getLogger(EmailService::class.java)

  /**
   * Send a simple text email
   */
  suspend fun sendEmail(request: EmailRequest): Boolean {
    if (sesClient == null || !awsSesProperties.enabled) {
      logger.warn("SES is disabled. Email not sent to: ${request.to}")
      return false
    }

    return try {
      withContext(Dispatchers.IO) {
        val destination = Destination.builder()
          .toAddresses(request.to)
          .build()

        val bodyContent = if (request.htmlBody != null) {
          // Send HTML email with text fallback
          Body.builder()
            .html(Content.builder().data(request.htmlBody).charset("UTF-8").build())
            .text(Content.builder().data(request.body).charset("UTF-8").build())
            .build()
        } else {
          // Send plain text email
          Body.builder()
            .text(Content.builder().data(request.body).charset("UTF-8").build())
            .build()
        }

        val message = Message.builder()
          .subject(Content.builder().data(request.subject).charset("UTF-8").build())
          .body(bodyContent)
          .build()

        val sendRequestBuilder = SendEmailRequest.builder()
          .destination(destination)
          .message(message)
          .source("${awsSesProperties.fromName} <${awsSesProperties.fromEmail}>")

        // Add reply-to if provided
        if (!request.replyTo.isNullOrBlank()) {
          sendRequestBuilder.replyToAddresses(request.replyTo)
        }

        val response = sesClient.sendEmail(sendRequestBuilder.build())
        logger.info("Email sent successfully to: ${request.to}, MessageId: ${response.messageId()}")
        true
      }
    } catch (e: Exception) {
      logger.error("Failed to send email to: ${request.to}", e)
      false
    }
  }

  /**
   * Send contact form notification to admin
   */
  suspend fun sendContactFormNotification(data: ContactFormEmailData): Boolean {
    val subject = emailProperties.contactSubject
    val textBody = buildContactFormTextBody(data)
    val htmlBody = buildContactFormHtmlBody(data)

    return sendEmail(
      EmailRequest(
        to = emailProperties.adminEmail,
        subject = subject,
        body = textBody,
        htmlBody = htmlBody,
        replyTo = data.email
      )
    )
  }

  /**
   * Build plain text email body for contact form
   */
  private fun buildContactFormTextBody(data: ContactFormEmailData): String {
    return """
      New Contact Form Submission
      
      Name: ${data.name}
      Email: ${data.email}
      Time: ${data.timestamp}
      
      Message:
      ${data.message}
      
      ---
      You can reply directly to this email to respond to ${data.name}.
    """.trimIndent()
  }

  /**
   * Build HTML email body for contact form
   */
  private fun buildContactFormHtmlBody(data: ContactFormEmailData): String {
    return """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>New Contact Form Submission</title>
      </head>
      <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background-color: #f8f9fa; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
          <h2 style="color: #2c3e50; margin-top: 0;">📬 New Contact Form Submission</h2>
        </div>
        
        <div style="background-color: #ffffff; border: 1px solid #e9ecef; border-radius: 8px; padding: 20px;">
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 8px 0; font-weight: 600; color: #495057; width: 100px;">Name:</td>
              <td style="padding: 8px 0;">${escapeHtml(data.name)}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: 600; color: #495057;">Email:</td>
              <td style="padding: 8px 0;"><a href="mailto:${escapeHtml(data.email)}" style="color: #007bff; text-decoration: none;">${escapeHtml(data.email)}</a></td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: 600; color: #495057;">Time:</td>
              <td style="padding: 8px 0; color: #6c757d;">${escapeHtml(data.timestamp)}</td>
            </tr>
          </table>
          
          <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e9ecef;">
            <p style="font-weight: 600; color: #495057; margin-bottom: 10px;">Message:</p>
            <div style="background-color: #f8f9fa; border-left: 4px solid #007bff; padding: 15px; border-radius: 4px; white-space: pre-wrap; word-wrap: break-word;">
              ${escapeHtml(data.message)}
            </div>
          </div>
        </div>
        
        <div style="margin-top: 20px; padding: 15px; background-color: #e7f3ff; border-radius: 8px;">
          <p style="margin: 0; color: #004085; font-size: 14px;">
            💡 <strong>Tip:</strong> You can reply directly to this email to respond to ${escapeHtml(data.name)}.
          </p>
        </div>
        
        <div style="margin-top: 20px; text-align: center; color: #6c757d; font-size: 12px;">
          <p>This is an automated notification from your blog contact form.</p>
        </div>
      </body>
      </html>
    """.trimIndent()
  }

  /**
   * Escape HTML to prevent XSS in email templates
   */
  private fun escapeHtml(text: String): String {
    return text
      .replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&#39;")
  }
}

