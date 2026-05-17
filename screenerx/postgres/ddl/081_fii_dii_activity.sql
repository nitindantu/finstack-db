-- ============================================================
-- Table: fii_dii_activity
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.fii_dii_activity (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    activity_date   DATE            NOT NULL,
    fii_buy         NUMERIC(18,2)   NOT NULL DEFAULT 0,
    fii_sell        NUMERIC(18,2)   NOT NULL DEFAULT 0,
    fii_net         NUMERIC(18,2)   GENERATED ALWAYS AS (fii_buy - fii_sell) STORED,
    dii_buy         NUMERIC(18,2)   NOT NULL DEFAULT 0,
    dii_sell        NUMERIC(18,2)   NOT NULL DEFAULT 0,
    dii_net         NUMERIC(18,2)   GENERATED ALWAYS AS (dii_buy - dii_sell) STORED,
    segment         VARCHAR(20)     NOT NULL DEFAULT 'equity' CHECK (segment IN ('equity','debt','hybrid')),
    source          VARCHAR(100)    NOT NULL DEFAULT 'NSE',
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT fii_dii_activity_pkey PRIMARY KEY (id),
    CONSTRAINT fii_dii_activity_date_segment_uq UNIQUE (activity_date, segment)
);

CREATE INDEX IF NOT EXISTS idx_fii_dii_date ON screenerx.fii_dii_activity (activity_date DESC);

COMMENT ON TABLE screenerx.fii_dii_activity IS 'Daily FII (Foreign Institutional Investors) and DII (Domestic Institutional Investors) buy/sell activity in crore INR';
