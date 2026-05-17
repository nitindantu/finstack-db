-- ============================================================
-- Table: brokers
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS brokers (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    name                    VARCHAR(255) NOT NULL,
    code                    VARCHAR(20) NOT NULL,
    api_base_url            TEXT,
    supported_exchanges     TEXT[]      NOT NULL DEFAULT '{}',
    features                JSONB       NOT NULL DEFAULT '{}',
    is_active               BOOLEAN     NOT NULL DEFAULT TRUE,
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT brokers_pkey PRIMARY KEY (id),
    CONSTRAINT brokers_code_unique UNIQUE (code)
);

COMMENT ON TABLE brokers IS 'Registered broker integrations available on the platform';
COMMENT ON COLUMN brokers.code IS 'Short broker identifier, e.g. ZERODHA, UPSTOX, ANGEL, HDFC';
COMMENT ON COLUMN brokers.features IS 'JSON map of feature flags: {gtc: true, amo: true, options: false, ...}';
