-- ============================================================
-- Table: exchanges
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.exchanges (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    code            VARCHAR(20) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    country         CHAR(2)     NOT NULL,
    currency        CHAR(3)     NOT NULL DEFAULT 'INR',
    timezone        VARCHAR(60) NOT NULL DEFAULT 'Asia/Kolkata',
    trading_hours   JSONB       NOT NULL DEFAULT '{}',
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT exchanges_pkey PRIMARY KEY (id),
    CONSTRAINT exchanges_code_unique UNIQUE (code),
    CONSTRAINT exchanges_country_format CHECK (country ~ '^[A-Z]{2}$'),
    CONSTRAINT exchanges_currency_format CHECK (currency ~ '^[A-Z]{3}$')
);

COMMENT ON TABLE exchanges IS 'Stock and derivatives exchanges supported by the platform';
COMMENT ON COLUMN exchanges.code IS 'Short exchange code, e.g. NSE, BSE, NYSE, NASDAQ';
COMMENT ON COLUMN exchanges.country IS 'ISO 3166-1 alpha-2 country code';
COMMENT ON COLUMN exchanges.currency IS 'ISO 4217 base currency of the exchange';
COMMENT ON COLUMN exchanges.trading_hours IS 'JSON mapping day-of-week to open/close times in local timezone';
