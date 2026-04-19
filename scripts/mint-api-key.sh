#!/usr/bin/env bash
# Mint an admin API key for the blog backend.
#
# Usage:
#   ./scripts/mint-api-key.sh "publish-pipeline"
#
# Output: prints the full key (public_id.secret) exactly once — save it.
# The DB only stores the SHA-256 hash of the secret portion.
#
# Requires: openssl, psql, and a live connection to the prod Postgres.
# Export DATABASE_URL in the form: postgresql://user:pass@host:port/db
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <key-name> [role1,role2,...]" >&2
  exit 1
fi

NAME="$1"
ROLES_CSV="${2:-ADMIN}"

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL not set (e.g. postgresql://user:pass@host:5432/personal)" >&2
  exit 1
fi

# 16-byte public id, 32-byte secret; both url-safe base64, no padding.
PUBLIC_ID="$(openssl rand -base64 16 | tr '+/' '-_' | tr -d '=')"
SECRET="$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')"
FULL_KEY="${PUBLIC_ID}.${SECRET}"
HASH="$(printf %s "$SECRET" | openssl dgst -sha256 | awk '{print $2}')"

# Roles as Postgres array literal
ROLES_ARRAY="ARRAY[$(echo "$ROLES_CSV" | awk -F, '{for(i=1;i<=NF;i++){printf "%s'\''%s'\''", (i>1?",":""), $i}}')]::TEXT[]"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
INSERT INTO api_keys (public_id, key_hash, name, roles)
VALUES ('$PUBLIC_ID', '$HASH', '$(printf %s "$NAME" | sed "s/'/''/g")', $ROLES_ARRAY);
SQL

echo
echo "=========================================================="
echo "API KEY (save this — it is NOT stored and cannot be recovered):"
echo
echo "  $FULL_KEY"
echo
echo "Use as:  curl -H 'X-API-Key: $FULL_KEY' ..."
echo "=========================================================="
