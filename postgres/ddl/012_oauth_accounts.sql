-- ============================================================
-- Table: oauth_accounts
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS oauth_accounts (
    id                          UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id                     UUID            NOT NULL,
    provider                    oauth_provider  NOT NULL,
    provider_user_id            VARCHAR(255)    NOT NULL,
    access_token_encrypted      TEXT,
    refresh_token_encrypted     TEXT,
    expires_at                  TIMESTAMPTZ,
    metadata                    JSONB           NOT NULL DEFAULT '{}',
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT oauth_accounts_pkey PRIMARY KEY (id),
    CONSTRAINT oauth_accounts_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT oauth_accounts_provider_user_unique UNIQUE (provider, provider_user_id)
);

COMMENT ON TABLE oauth_accounts IS 'Linked OAuth/social login identities for users';
COMMENT ON COLUMN oauth_accounts.provider IS 'OAuth provider name (google, github, etc.)';
COMMENT ON COLUMN oauth_accounts.provider_user_id IS 'User ID as returned by the OAuth provider';
COMMENT ON COLUMN oauth_accounts.access_token_encrypted IS 'AES-256-GCM encrypted OAuth access token';
COMMENT ON COLUMN oauth_accounts.refresh_token_encrypted IS 'AES-256-GCM encrypted OAuth refresh token';
