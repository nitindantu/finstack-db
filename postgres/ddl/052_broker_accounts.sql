-- ============================================================
-- Table: broker_accounts
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS broker_accounts (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID            NOT NULL,
    broker_id               UUID            NOT NULL,
    account_id              VARCHAR(100)    NOT NULL,
    account_type            account_type    NOT NULL DEFAULT 'trading',
    api_key_encrypted       TEXT,
    api_secret_encrypted    TEXT,
    is_active               BOOLEAN         NOT NULL DEFAULT TRUE,
    balance                 NUMERIC(20,2)   NOT NULL DEFAULT 0,
    margin_available        NUMERIC(20,2)   NOT NULL DEFAULT 0,
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT broker_accounts_pkey PRIMARY KEY (id),
    CONSTRAINT broker_accounts_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT broker_accounts_broker_fk FOREIGN KEY (broker_id) REFERENCES brokers (id) ON DELETE RESTRICT,
    CONSTRAINT broker_accounts_broker_account_unique UNIQUE (broker_id, account_id)
);

COMMENT ON TABLE broker_accounts IS 'User broker account linkages with encrypted API credentials';
COMMENT ON COLUMN broker_accounts.api_key_encrypted IS 'AES-256-GCM encrypted broker API key';
COMMENT ON COLUMN broker_accounts.api_secret_encrypted IS 'AES-256-GCM encrypted broker API secret';
COMMENT ON COLUMN broker_accounts.balance IS 'Available cash balance as last synced from broker';
COMMENT ON COLUMN broker_accounts.margin_available IS 'Available margin/leverage as last synced from broker';
