-- ============================================================
-- Table: sessions
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS sessions (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    token_hash      VARCHAR(256) NOT NULL,
    device_id       VARCHAR(255),
    ip_address      INET,
    user_agent      TEXT,
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT sessions_pkey PRIMARY KEY (id),
    CONSTRAINT sessions_token_hash_unique UNIQUE (token_hash),
    CONSTRAINT sessions_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT sessions_expires_after_created CHECK (expires_at > created_at)
);

COMMENT ON TABLE sessions IS 'Active and historical user authentication sessions';
COMMENT ON COLUMN sessions.token_hash IS 'SHA-256 hash of the bearer/refresh token stored client-side';
COMMENT ON COLUMN sessions.device_id IS 'Client-generated device fingerprint';
COMMENT ON COLUMN sessions.ip_address IS 'IP address at session creation';
COMMENT ON COLUMN sessions.revoked_at IS 'Non-NULL means the session was explicitly invalidated before expiry';
