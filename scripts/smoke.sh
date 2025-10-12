#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}

echo "[smoke] GET /api/meta"
curl -fsS "$BASE_URL/api/meta" | jq . || true

echo "[smoke] GET /api/projects"
curl -fsS "$BASE_URL/api/projects" | jq . || true

echo "[smoke] GET /api/testimonials"
curl -fsS "$BASE_URL/api/testimonials" | jq . || true

echo "[smoke] GET /api/resume"
curl -fsS "$BASE_URL/api/resume" | jq . || true

echo "[smoke] GET /api/posts"
curl -fsS "$BASE_URL/api/posts" | jq . || true

if [ -n "${SMOKE_POST_SLUG:-}" ]; then
  echo "[smoke] GET /api/posts/$SMOKE_POST_SLUG"
  curl -fsS "$BASE_URL/api/posts/$SMOKE_POST_SLUG" | jq . || true
fi

echo "[smoke] POST /api/contact"
curl -fsS -X POST "$BASE_URL/api/contact" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Smoke","email":"smoke@example.com","message":"Hello","website":""}' | jq . || true

echo "[smoke] done"


