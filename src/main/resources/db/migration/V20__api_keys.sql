-- API keys for programmatic admin access (e.g., blog publishing pipelines).
-- Stores a SHA-256 hash of the secret portion; the plaintext key is shown
-- to the operator only once at mint time.
--
-- Key format presented to clients:
--   <public_id>.<secret>
-- Lookup: resolve row by public_id (indexed), compare sha256(secret) to key_hash.

CREATE TABLE IF NOT EXISTS api_keys (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  public_id   TEXT        NOT NULL UNIQUE,
  key_hash    TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  roles       TEXT[]      NOT NULL DEFAULT ARRAY['ADMIN'],
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_used_at TIMESTAMPTZ,
  revoked_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_api_keys_public_id_active
  ON api_keys (public_id)
  WHERE revoked_at IS NULL;
