# Personal Site — Backend (Spring WebFlux + Kotlin + Postgres)

This document describes domain, API, security, storage, and deployment.

## Tech Stack

- Kotlin + Spring Boot (WebFlux + Coroutines) avoid using mono / flux
- Spring Security (Resource Server, JWT) Keycloak
- R2DBC Postgres, Flyway
- Micrometer + Actuator
- OpenAPI (springdoc)

---

## Domain & Tables

**post**
- `id UUID PK`
- `slug TEXT UNIQUE`
- `title TEXT`
- `excerpt TEXT`
- `content_mdx TEXT`
- `cover_url TEXT NULL`
- `tags TEXT[]`
- `status TEXT CHECK (status in ('draft','published')) DEFAULT 'draft'`
- `published_at TIMESTAMPTZ NULL`
- `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`

**project**
- `id UUID PK`, `slug UNIQUE`, `title`, `summary`, `content_mdx`, `links JSONB`, `order INT`

**testimonial**
- `id UUID PK`, `author`, `role`, `avatar_url`, `quote`, `order INT`

**resume_section**
- `id UUID PK`, `kind TEXT`, `content_json JSONB`, `order INT`

**contact_message**
- `id UUID PK`, `name`, `email`, `message`, `created_at TIMESTAMPTZ DEFAULT now()`, `handled BOOLEAN DEFAULT FALSE`

**site_meta**
- `id SMALLINT PK=1`, `email`, `location`, `socials JSONB`, `hero JSONB`

**Indexes**
- `post(status, published_at desc)`, `GIN(tags)`, `project(order)`, `testimonial(order)`

---

## Flyway Example

`V1__init.sql`
```sql
create extension if not exists "uuid-ossp";

create table post(
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  excerpt text not null,
  content_mdx text not null,
  cover_url text,
  tags text[] not null default '{}',
  status text not null default 'draft' check (status in ('draft','published')),
  published_at timestamptz,
  updated_at timestamptz not null default now()
);

create index idx_post_status_published_at on post(status, published_at desc);

create table project(
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  summary text not null,
  content_mdx text not null,
  links jsonb not null default '{}',
  "order" int not null default 0
);
create index idx_project_order on project("order");

create table testimonial(
  id uuid primary key default uuid_generate_v4(),
  author text not null,
  role text not null,
  avatar_url text,
  quote text not null,
  "order" int not null default 0
);
create index idx_testimonial_order on testimonial("order");

create table resume_section(
  id uuid primary key default uuid_generate_v4(),
  kind text not null,
  content_json jsonb not null default '{}',
  "order" int not null default 0
);

create table contact_message(
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  email text not null,
  message text not null,
  created_at timestamptz not null default now(),
  handled boolean not null default false
);

create table site_meta(
  id smallint primary key,
  email text,
  location text,
  socials jsonb not null default '{}',
  hero jsonb not null default '{}'
);

insert into site_meta(id, email, location, socials, hero)
values(1, 'me@jirihermann.com', 'Prague, CZ', '{}', '{}');
```

---

## Gradle (key parts)

```kotlin
plugins {
  kotlin("jvm") version "2.0.0"
  kotlin("plugin.spring") version "2.0.0"
  id("org.springframework.boot") version "3.3.4"
  id("io.spring.dependency-management") version "1.1.6"
  id("org.flywaydb.flyway") version "9.22.3"
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
  implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
  implementation("org.springframework.boot:spring-boot-starter-validation")
  implementation("org.springframework.boot:spring-boot-starter-actuator")

  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor:1.9.0")
  implementation("org.springframework.data:spring-data-r2dbc")
  runtimeOnly("org.postgresql:postgresql")
  runtimeOnly("org.postgresql:r2dbc-postgresql")

  implementation("org.springdoc:springdoc-openapi-starter-webflux-ui:2.6.0")

  testImplementation("org.springframework.boot:spring-boot-starter-test")
  testImplementation("io.projectreactor:reactor-test")
}
```

---

## Configuration

`application.yml`
```yaml
server:
  port: 8080

spring:
  r2dbc:
    url: r2dbc:postgresql://localhost:5432/personal
    username: personal
    password: personal
  flyway:
    enabled: true
    url: jdbc:postgresql://localhost:5432/personal
    user: personal
    password: personal
  jackson:
    serialization:
      WRITE_DATES_AS_TIMESTAMPS: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics

security:
  allowed-origins: "http://localhost:3333"

spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081/realms/personal
```

CORS: allow FE domain for `/api`.

---

## API (Contracts)

**Public**
- `GET /api/meta`
- `GET /api/posts?limit=&tag=&cursor=`
- `GET /api/posts/{slug}`
- `GET /api/projects`
- `GET /api/testimonials`
- `GET /api/resume`
- `POST /api/contact` → `202 Accepted`

**Admin (JWT required, role `ROLE_ADMIN`)**
- `POST /api/posts`
- `PUT /api/posts/{id}`
- `DELETE /api/posts/{id}`
- Same for `/api/projects` and `/api/testimonials`
- `GET /api/contact?handled=false`
- `PUT /api/contact/{id}:handle`

**Response examples**

`GET /api/posts?limit=10`
```json
{
  "items": [
    {
      "slug": "clean-code-essentials",
      "title": "Clean Code Essentials",
      "excerpt": "…",
      "tags": ["web","craft"],
      "published_at": "2025-04-30T10:00:00Z",
      "cover_url": null
    }
  ],
  "nextCursor": null
}
```

`GET /api/posts/clean-code-essentials`
```json
{
  "slug": "clean-code-essentials",
  "title": "Clean Code Essentials",
  "content_mdx": "# MDX here\n\nSome content…",
  "tags": ["web","craft"],
  "published_at": "2025-04-30T10:00:00Z"
}
```

---

## Controllers (sketch)

```kotlin
@RestController
@RequestMapping("/api/posts")
class PostController(private val service: PostService) {
  @GetMapping
  suspend fun list(
    @RequestParam(required = false) limit: Int?,
    @RequestParam(required = false) tag: String?,
    @RequestParam(required = false) cursor: String?
  ) = service.list(limit ?: 10, tag, cursor)

  @GetMapping("/{slug}")
  suspend fun get(@PathVariable slug: String) = service.getBySlug(slug)
}
```

---

## Entities & Repositories (R2DBC)

```kotlin
@Table("post")
data class PostEntity(
  @Id val id: UUID? = null,
  val slug: String,
  val title: String,
  val excerpt: String,
  val content_mdx: String,
  val cover_url: String?,
  val tags: List<String> = emptyList(),
  val status: String = "draft",
  val published_at: OffsetDateTime? = null,
  val updated_at: OffsetDateTime = OffsetDateTime.now()
)

interface PostRepo : CoroutineCrudRepository<PostEntity, UUID> {
  @Query("""
    select * from post
    where status = 'published'
      and (:tag is null or :tag = any(tags))
    order by published_at desc nulls last
    limit :limit
  """)
  suspend fun listPublished(limit: Int, tag: String?): List<PostEntity>

  @Query("""select * from post where slug = :slug and status in ('published','draft')""")
  suspend fun findBySlug(slug: String): PostEntity?
}
```

---

## Security

- Spring Security Resource Server w/ Keycloak issuer.
- Map Keycloak realm/client roles to `ROLE_ADMIN`.
- Rate limit `POST /api/contact` (ip-based) + honeypot.

```kotlin
@Configuration
class SecurityConfig {
  @Bean
  fun filterChain(http: ServerHttpSecurity): SecurityWebFilterChain =
    http.csrf { it.disable() }
      .authorizeExchange {
        it.pathMatchers(HttpMethod.GET, "/api/**").permitAll()
        it.pathMatchers("/api/contact").permitAll()
        it.pathMatchers("/api/**").hasRole("ADMIN")
        it.anyExchange().permitAll()
      }
      .oauth2ResourceServer { it.jwt() }
      .build()
}
```

---

## OpenAPI

- springdoc UI at `/swagger-ui.html` for admin/dev.

---

## Deployment

- **BE**: Docker image, expose `8080`, run Flyway on startup.
- **DB**: Postgres 15+, create user/db, network only from BE.
- **FE**: static host (CF Pages/Vercel) → set `VITE_API_BASE` to BE URL.
- **TLS**: Reverse proxy (Nginx/Caddy) in front of BE.
- **Observability**: Actuator health, metrics, logs with correlation IDs.

---

## cURL Smoke Test

```bash
# public
curl http://localhost:8080/api/posts

# contact
curl -X POST http://localhost:8080/api/contact   -H 'Content-Type: application/json'   -d '{"name":"Jiri","email":"me@jirihermann.com","message":"Let’s build X."}'

# admin (replace TOKEN)
curl http://localhost:8080/api/contact -H "Authorization: Bearer $TOKEN"
```

---

## Definition of Done (BE)

- Flyway migrations applied; tables exist.
- Public endpoints return data; pagination OK.
- Admin endpoints protected by JWT and role.
- Contact endpoint stores messages and rate-limits abuse.
- OpenAPI available; health endpoint green.
- CI build + Docker image; config via env.
