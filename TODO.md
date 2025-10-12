## Backend TODO

### Project Init
- [x] Initialize Kotlin + Spring Boot (WebFlux + Coroutines)
- [x] Add Gradle Kotlin DSL with plugins per `docs/BE.md`
- [x] Add dependencies: WebFlux, Security (JWT Resource Server), Validation, Actuator, R2DBC Postgres, Flyway, springdoc-openapi

### Database & Migrations
- [x] Configure R2DBC and Flyway (JDBC) connections
- [x] Create `V1__init.sql` with tables: post, project, testimonial, resume_section, contact_message, site_meta, indexes

### Configuration
- [x] Add `application.yml` with server, spring (r2dbc, flyway, jackson), management, security (issuer URI), CORS allowed origins

### Domain & Repositories
- [x] Define entities (R2DBC) and coroutine repositories (e.g., `PostEntity`, `PostRepo`)

### API
- [x] Public endpoints: meta, posts (list/detail), projects, testimonials, resume, contact
- [x] Admin endpoints (CRUD for posts/projects/testimonials, contact moderation)
- [x] Rate-limit + honeypot for contact

### Security
- [x] Resource Server JWT with Keycloak issuer
- [x] Role mapping to `ROLE_ADMIN`
- [x] CORS for FE domain

### Observability & Docs
- [x] Actuator health/info/metrics
- [x] OpenAPI via springdoc (UI enabled for admin/dev)

### Deployment
- [x] Dockerfile
- [x] CI build
- [x] Config via environment variables

### Smoke Tests
- [x] cURL scripts to verify public/admin endpoints

### Definition of Done
- [ ] Flyway migrations applied; tables exist
- [ ] Public endpoints return data; pagination OK
- [ ] Admin endpoints protected by JWT and role
- [ ] Contact endpoint stores messages and rate-limits abuse
- [ ] OpenAPI available; health endpoint green
- [ ] CI build + Docker image; config via env



