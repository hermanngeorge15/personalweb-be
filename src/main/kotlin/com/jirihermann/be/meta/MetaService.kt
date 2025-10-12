package com.jirihermann.be.meta

import org.springframework.stereotype.Service

data class MetaDto(
  val email: String?,
  val location: String?,
  val socials: String,
  val hero: String
)

@Service
class MetaService(private val repo: SiteMetaRepo) {
  suspend fun get(): MetaDto? = repo.findById(1)?.let {
    MetaDto(
      email = it.email,
      location = it.location,
      socials = it.socials,
      hero = it.hero
    )
  }
}


