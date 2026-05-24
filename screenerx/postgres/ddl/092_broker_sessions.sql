-- ============================================================
-- Table: broker_sessions
-- Domain: Trading / Kite Connect
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.broker_sessions (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    broker_account_id       UUID            NOT NULL,
    request_token           VARCHAR(255),
    access_token_encrypted  TEXT            NOT NULL,
    -- AES-128 Fernet-encrypted. Never stored in plaintext.
    public_token            VARCHAR(255),
    login_time              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    token_expiry            TIMESTAMPTZ     NOT NULL,
    -- Kite tokens expire at 06:00 IST daily (stored as UTC 00:30)
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT broker_sessions_pkey PRIMARY KEY (id),
    CONSTRAINT broker_sessions_account_fk FOREIGN KEY (broker_account_id)
        REFERENCES quantnova.broker_accounts (id) ON DELETE CASCADE
);

-- Only one active session per broker account at a time
CREATE UNIQUE INDEX IF NOT EXISTS idx_broker_sessions_active
    ON screenerx.broker_sessions (broker_account_id)
    WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_broker_sessions_account
    ON screenerx.broker_sessions (broker_account_id, created_at DESC);
