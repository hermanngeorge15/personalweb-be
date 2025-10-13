package com.jirihermann.be.email

data class EmailRequest(
  val to: String,
  val subject: String,
  val body: String,
  val htmlBody: String? = null,
  val replyTo: String? = null
)

data class ContactFormEmailData(
  val name: String,
  val email: String,
  val message: String,
  val timestamp: String
)

