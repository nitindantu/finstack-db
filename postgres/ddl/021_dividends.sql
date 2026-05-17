-- ============================================================
-- Table: dividends
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS dividends (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    symbol_id       UUID            NOT NULL,
    declared_date   DATE,
    ex_date         DATE            NOT NULL,
    record_date     DATE,
    payment_date    DATE,
    dividend_type   dividend_type   NOT NULL DEFAULT 'final',
    amount          NUMERIC(12,6)   NOT NULL CHECK (amount > 0),
    currency        CHAR(3)         NOT NULL DEFAULT 'INR',
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT dividends_pkey PRIMARY KEY (id),
    CONSTRAINT dividends_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    CONSTRAINT dividends_currency_format CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT dividends_record_after_ex CHECK (record_date IS NULL OR record_date >= ex_date),
    CONSTRAINT dividends_payment_after_record CHECK (payment_date IS NULL OR record_date IS NULL OR payment_date >= record_date)
);

COMMENT ON TABLE dividends IS 'Dividend history per symbol including interim, final and special dividends';
COMMENT ON COLUMN dividends.declared_date IS 'Board meeting date when dividend was announced';
COMMENT ON COLUMN dividends.amount IS 'Dividend per share in the stated currency';
COMMENT ON COLUMN dividends.dividend_type IS 'interim = mid-year, final = annual, special = one-off';
