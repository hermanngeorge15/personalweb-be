package com.jirihermann.be.meta

import org.springframework.data.annotation.Id
import org.springframework.data.relational.core.mapping.Table

@Table("site_meta")
data class SiteMetaEntity(
  @Id val id: Short,
  val email: String?,
  val location: String?,
  val socials: String,
  val hero: String
)


