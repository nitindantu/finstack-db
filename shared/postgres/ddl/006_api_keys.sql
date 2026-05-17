-- ============================================================
-- Table: api_keys
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.api_keys (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    tenant_id       UUID        NOT NULL,
    key_hash        VARCHAR(256) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    scopes          TEXT[]      NOT NULL DEFAULT '{}',
    rate_limit      INTEGER     NOT NULL DEFAULT 1000 CHECK (rate_limit > 0),
    last_used_at    TIMESTAMPTZ,
    expires_at      TIMESTAMPTZ,
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT api_keys_pkey PRIMARY KEY (id),
    CONSTRAINT api_keys_key_hash_unique UNIQUE (key_hash),
    CONSTRAINT api_keys_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT api_keys_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE api_keys IS 'Programmatic API keys for users; key value itself is never stored, only its hash';
COMMENT ON COLUMN api_keys.key_hash IS 'SHA-256 of the raw API key shown to user once on creation';
COMMENT ON COLUMN api_keys.scopes IS 'Array of permission codes this key is restricted to';
COMMENT ON COLUMN api_keys.rate_limit IS 'Max requests per minute for this key';
