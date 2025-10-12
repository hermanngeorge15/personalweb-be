## Frontend Integration Guide

### 1) Base URL & Envs
- Local API base: `http://localhost:8080`
- Frontend env (Vite/Next):
  - `VITE_API_BASE=http://localhost:8080`
- In production, set to your BE URL (behind TLS/ingress).

### 2) CORS
- Backend allows origins via `security.allowed-origins` (env `ALLOWED_ORIGINS`).
- Ensure your FE dev server origin (e.g. `http://localhost:3333`) is present.

### 3) OpenAPI & Swagger UI
- OpenAPI JSON: `GET /v3/api-docs`
- Swagger UI: open `/swagger-ui.html` (redirects to `/webjars/swagger-ui/index.html`).

### 4) Public Endpoints (no auth)
- `GET /api/meta`
- `GET /api/posts?limit=&tag=&cursor=` (cursor-based pagination)
- `GET /api/posts/{slug}`
- `GET /api/projects`
- `GET /api/testimonials`
- `GET /api/resume`
- `POST /api/contact` (rate-limited + honeypot) body: `{ name, email, message, website:"" }`

Pagination notes:
- Responses shape:
```json
{
  "items": [ /* ... */ ],
  "nextCursor": "..." | null
}
```
- Pass `nextCursor` to `cursor=` for the next page.

### 5) Admin Endpoints (JWT required, role `ROLE_ADMIN`)
- CRUD for `/api/posts`, `/api/projects`, `/api/testimonials`
- `GET /api/contact?handled=false` and `POST /api/contact/{id}:handle`
- Auth header: `Authorization: Bearer <token>`

Keycloak (high-level):
- Realm `personal`; configure a Client (public/bearer), add role `admin`.
- Assign role to user. Map realm/client roles → authorities (done in BE).
- FE obtains tokens via your chosen flow (PKCE or dev token), include in requests.

### 6) Error Handling
- 404 for missing slugs/resources.
- 400 validation errors on `POST /api/contact` (invalid `email`/`name`/`message`).
- 401/403 for admin endpoints without proper JWT/role.

### 7) Examples (TypeScript)

Simple API client factory:
```ts
export function api(base = import.meta.env.VITE_API_BASE || "") {
  return async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const res = await fetch(`${base}${path}`, {
      headers: { "Content-Type": "application/json", ...(init?.headers || {}) },
      ...init,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => "");
      throw new Error(`HTTP ${res.status} ${res.statusText} ${text}`);
    }
    if (res.status === 204) return undefined as T;
    return (await res.json()) as T;
  };
}
```

Fetch posts (paginated):
```ts
type PostListItem = {
  slug: string; title: string; excerpt: string; tags: string[];
  published_at?: string; cover_url?: string | null;
};
type Page<T> = { items: T[]; nextCursor?: string | null };

const request = api();

export async function fetchPosts(limit = 10, tag?: string, cursor?: string) {
  const q = new URLSearchParams();
  q.set("limit", String(limit));
  if (tag) q.set("tag", tag);
  if (cursor) q.set("cursor", cursor);
  return request<Page<PostListItem>>(`/api/posts?${q.toString()}`);
}

export async function fetchPost(slug: string) {
  return request(`/api/posts/${encodeURIComponent(slug)}`);
}
```

Submit contact form (honeypot empty):
```ts
export async function submitContact(name: string, email: string, message: string) {
  return request(`/api/contact`, {
    method: "POST",
    body: JSON.stringify({ name, email, message, website: "" }),
  });
}
```

Admin call with JWT:
```ts
export async function createPost(token: string, body: any) {
  return request(`/api/posts`, {
    method: "POST",
    body: JSON.stringify(body),
    headers: { Authorization: `Bearer ${token}` },
  });
}
```

### 8) Local Dev Checklist
- Start BE + DB: `docker compose up -d --build`
- FE env: `VITE_API_BASE=http://localhost:8080`
- FE dev server: e.g. `http://localhost:3333` (ensure CORS origin matches)
- Docs: `/swagger-ui.html` and `/v3/api-docs`

### 9) Production Checklist
- API behind TLS (ingress/reverse proxy)
- Set FE `API_BASE` to public BE URL
- Configure `ALLOWED_ORIGINS` to FE origin(s)
- Keycloak issuer URL set in env `JWT_ISSUER_URI`
- Verify health `/actuator/health` and metrics `/actuator/prometheus`

### 10) Troubleshooting
- CORS error: check `ALLOWED_ORIGINS` and FE origin.
- 401/403 on admin: verify token contains `admin` role.
- Pagination: always pass `nextCursor` from the last response to fetch next page.


