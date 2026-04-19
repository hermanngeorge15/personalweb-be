# personalweb-be — API spec

Version: 1 (2026-04-19). Covers the endpoints exercised by external publishing
pipelines (e.g. the LinkedIn article pipeline). Not an exhaustive map of every
endpoint — see `/v3/api-docs` for the full OpenAPI document when logged in.

Base URL (prod): `https://jirihermann.com`

## 1. Authentication

Two mechanisms are supported. Clients pick one per request — they do not mix.

### 1.1 Keycloak JWT (`Authorization: Bearer …`)

Interactive users. Frontend logs in via Keycloak at
`https://keycloak.kotlinserversquad.com/realms/personalblog`. The access token
is a standard OIDC JWT; Spring maps realm/client roles to
`ROLE_<UPPERCASE_ROLE>`.

### 1.2 API key (`X-API-Key: <public_id>.<secret>`)

Machine clients. A key is a `"<public_id>.<secret>"` string. The backend
resolves `public_id` by indexed lookup, SHA-256-hashes the `secret`, and
constant-time-compares to the stored `key_hash`. Revoked keys (`revoked_at IS
NOT NULL`) are ignored. On match, the filter populates the reactive security
context with the key's roles (default: `ROLE_ADMIN`) and proceeds; the JWT
filter then no-ops because an authentication is already present.

Minting (operator on the prod host):

```bash
export DATABASE_URL="postgresql://…"
./scripts/mint-api-key.sh "publish-pipeline"
# prints the full key exactly once — store it in your secrets manager
```

The plaintext key is **never** returned by any endpoint; only the SHA-256
of the secret is stored. If lost, revoke + mint a new one.

Revoking:

```sql
UPDATE api_keys SET revoked_at = now() WHERE name = 'publish-pipeline';
```

## 2. Posts

### 2.1 `GET /api/posts`

Public. Lists published posts.

Query: `limit` (default 10), `tag` (optional), `cursor` (optional, opaque).
Response: `{ "items": PostListItem[], "nextCursor": string | null }`.

### 2.2 `GET /api/posts/{slug}`

Public. `404` if not found.

### 2.3 `POST /api/posts`

Admin. Creates a new post. Returns `{ "id": "<uuid>" }`, status `201`.

Body (`application/json`):

```json
{
  "slug": "your-claude-md-is-broken",
  "title": "Your CLAUDE.md is broken",
  "excerpt": "One-liner preview.",
  "content_mdx": "# MDX body…",
  "cover_url": "/api/media/files/blog/abc123.gif",
  "tags": ["ai", "claude"],
  "status": "published",
  "published_at": "2026-04-19T20:00:00Z"
}
```

Field names are **snake_case** (the existing DTO convention). `status` is a
free-form string; `"published"` or `"draft"` by convention. `published_at` is
ISO-8601 with offset.

### 2.4 `PUT /api/posts/{id}`

Admin. Full replacement by UUID. Same body as create.

### 2.5 `PUT /api/posts/by-slug/{slug}` ★ new

Admin. Upsert by slug. Creates if missing, full-replaces if present.

Response: `{ "id": "<uuid>", "slug": "<slug>", "created": true|false }`.

Use this for idempotent publish pipelines — running the same script twice is
safe, the second run just updates.

### 2.6 `DELETE /api/posts/{id}`

Admin. `204 No Content`.

## 3. Media

### 3.1 `POST /api/media`

Admin. Multipart upload. `Content-Type: multipart/form-data`.

Form parts:
- `file` — the binary (required).
- `folder` — optional; sanitised to `[A-Za-z0-9_-]+`. Files get stored under
  `<base-dir>/<folder>/<sha256[:32]><ext>`.

Constraints: default max 20 MiB (`media.max-upload-bytes`). Allowed MIME prefixes
default to `image/`, `video/`, `application/pdf`.

Response:

```json
{
  "url": "/api/media/files/blog/a3f1…c9e2.gif",
  "filename": "blog/a3f1…c9e2.gif",
  "size": 945152,
  "contentType": "image/gif"
}
```

The returned `url` is site-relative. Use it directly as `cover_url` on a post
or inside MDX bodies — the frontend resolves it against the site origin.

### 3.2 `GET /api/media/files/{path}`

Public. Streams the file with `Cache-Control: public, max-age=31536000,
immutable`. Path is sanitised against directory traversal.

## 4. Reference: two-call publish flow

```bash
export BLOG_API_KEY="publish-pipeline-public.secret"
export BLOG_BASE="https://jirihermann.com"

GIF_URL=$(curl -sf -X POST "$BLOG_BASE/api/media" \
  -H "X-API-Key: $BLOG_API_KEY" \
  -F "file=@docs/linkedin-articles/gifs/01-spec-linter.gif" \
  -F "folder=blog" | jq -r .url)

jq --arg cover "$GIF_URL" \
   --arg mdx "$(cat docs/linkedin-articles/01-spec-linter.publish.md)" \
   '. + {cover_url: $cover, content_mdx: $mdx}' \
   docs/linkedin-articles/01-spec-linter.publish.json \
| curl -sf -X PUT "$BLOG_BASE/api/posts/by-slug/your-claude-md-is-broken" \
    -H "X-API-Key: $BLOG_API_KEY" \
    -H "Content-Type: application/json" \
    --data @-
```

## 5. Operational notes

- Uploaded media lives on the container filesystem at `MEDIA_BASE_DIR`
  (default `/app/media`). In prod, mount a host volume to survive image
  pulls — e.g. in `/opt/jiri-site/docker-compose.yml`:

  ```yaml
  services:
    backend:
      volumes:
        - media_data:/app/media
  volumes:
    media_data:
  ```

- `X-API-Key` is added to the CORS `Access-Control-Allow-Headers` list so
  browser clients could use keys too — but don't put keys in frontend bundles.
- No admin UI for API keys yet: mint/revoke through the script + SQL. Follow-up
  PR can add a proper management screen.
