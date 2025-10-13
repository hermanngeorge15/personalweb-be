# Personal Site — Backend

Kotlin + Spring Boot (WebFlux + Coroutines), Postgres (R2DBC + Flyway), JWT (Keycloak), springdoc, Actuator.

## Quickstart

- Build
```bash
./gradlew bootJar -x test
```

- Or use Makefile
```bash
make up     # build + start
make logs   # follow logs
make smoke  # run smoke tests
```

- Run with Docker (BE + DB)
```bash
docker compose up -d --build
```

- Seed sample post (optional)
```bash
docker compose exec -T db psql -U personal -d personal -c \
"insert into post(slug,title,excerpt,content_mdx,tags,status,published_at)
 values('hello-world','Hello','Intro','## Hi',array['web'],'published',now())
 on conflict do nothing;"
```

- Smoke tests
```bash
./scripts/smoke.sh
```

## Configuration
- `application.yml` supports env overrides for DB and Keycloak issuer.
- See `env.example` for common variables including AWS SES email setup.

## Email Notifications

Contact form submissions automatically send email notifications via AWS SES.

**Quick Setup (10 min):**
1. Verify sender email in [AWS SES Console](https://console.aws.amazon.com/ses/)
2. Create IAM user with SES permissions and get access keys
3. Configure environment variables (see `env.example`)
4. Test with `./scripts/test-email.sh`

**Documentation:**
- 🚀 [Quick Start Guide](./docs/AWS_SES_QUICK_START.md) - Get emails working in 10 minutes
- 📚 [Complete Setup Guide](./docs/AWS_SES_EMAIL_SETUP.md) - Detailed AWS SES setup
- 🚢 [Deployment Guide](./docs/EMAIL_DEPLOYMENT_GUIDE.md) - Production deployment
- 📋 [Feature Summary](./docs/EMAIL_FEATURE_SUMMARY.md) - Implementation overview

**Disable emails** (for local dev without AWS):
```bash
export SES_ENABLED=false
./gradlew bootRun
```

## Endpoints
- Public: `GET /api/meta`, `GET /api/posts`, `GET /api/posts/{slug}`, `GET /api/projects`, `GET /api/testimonials`, `GET /api/resume`, `POST /api/contact`
- Admin (JWT with `ROLE_ADMIN`): CRUD for posts, projects, testimonials; contact moderation
- Docs: `/swagger-ui.html`
- Health: `/actuator/health`

### CV PDF

- Endpoint: `GET /cv/{slug}.{lang}.pdf`
  - Content-Type: `application/pdf`
  - Headers: `ETag`, `Cache-Control: public, max-age=3600`, `Content-Disposition: inline; filename="CV-{FullName}-{lang}.pdf"`
  - Example:
    ```bash
    curl -i http://localhost:8080/cv/jiri.en.pdf -o jiri.en.pdf
    ```

Frontend usage (React):
```tsx
export function DownloadCvButton() {
  return (
    <a href={"http://localhost:8080/cv/jiri.en.pdf"} target="_blank" rel="noreferrer">
      Download PDF
    </a>
  );
}
```
