-- ============================================================
-- Table: ipos
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.ipos (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    company_name        VARCHAR(500)    NOT NULL,
    ticker              VARCHAR(50),
    exchange            VARCHAR(20)     NOT NULL DEFAULT 'NSE',
    issue_size_cr       NUMERIC(18,2),
    price_band_low      NUMERIC(10,2),
    price_band_high     NUMERIC(10,2),
    lot_size            INTEGER,
    open_date           DATE,
    close_date          DATE,
    allotment_date      DATE,
    listing_date        DATE,
    listing_price       NUMERIC(10,2),
    gmp                 NUMERIC(10,2),
    status              VARCHAR(20)     NOT NULL DEFAULT 'upcoming'
                            CHECK (status IN ('upcoming','open','closed','listed','withdrawn')),
    category            VARCHAR(50),
    registrar           VARCHAR(200),
    lead_managers       TEXT[],
    subscription_times  NUMERIC(8,2),
    min_investment      NUMERIC(10,2),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT ipos_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ipos_status ON screenerx.ipos (status);
CREATE INDEX IF NOT EXISTS idx_ipos_open_date ON screenerx.ipos (open_date);
CREATE INDEX IF NOT EXISTS idx_ipos_listing_date ON screenerx.ipos (listing_date);

COMMENT ON TABLE screenerx.ipos IS 'IPO tracker — upcoming, open, and recently listed IPOs with GMP and subscription data';
