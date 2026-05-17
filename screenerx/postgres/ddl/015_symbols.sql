-- ============================================================
-- Table: symbols
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.symbols (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    exchange_id         UUID            NOT NULL,
    ticker              VARCHAR(50)     NOT NULL,
    name                VARCHAR(500)    NOT NULL,
    isin                VARCHAR(12),
    cusip               VARCHAR(9),
    sector              VARCHAR(100),
    industry            VARCHAR(200),
    market_cap_category VARCHAR(20)     CHECK (market_cap_category IN ('large_cap','mid_cap','small_cap','micro_cap','nano_cap')),
    instrument_type     instrument_type NOT NULL DEFAULT 'equity',
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    listing_date        DATE,
    delisting_date      DATE,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT symbols_pkey PRIMARY KEY (id),
    CONSTRAINT symbols_exchange_fk FOREIGN KEY (exchange_id) REFERENCES screenerx.exchanges (id) ON DELETE RESTRICT,
    CONSTRAINT symbols_ticker_exchange_unique UNIQUE (ticker, exchange_id),
    CONSTRAINT symbols_isin_format CHECK (isin IS NULL OR isin ~ '^[A-Z]{2}[A-Z0-9]{9}[0-9]$'),
    CONSTRAINT symbols_cusip_format CHECK (cusip IS NULL OR char_length(cusip) = 9),
    CONSTRAINT symbols_delisting_after_listing CHECK (delisting_date IS NULL OR listing_date IS NULL OR delisting_date >= listing_date)
);

COMMENT ON TABLE symbols IS 'Master list of all tradeable and reference instruments';
COMMENT ON COLUMN symbols.ticker IS 'Exchange-specific trading symbol, e.g. RELIANCE, TCS, AAPL';
COMMENT ON COLUMN symbols.isin IS 'International Securities Identification Number (12 chars)';
COMMENT ON COLUMN symbols.cusip IS '9-character Committee on Uniform Securities Identification Procedures code';
COMMENT ON COLUMN symbols.market_cap_category IS 'Market capitalisation bucket: large/mid/small/micro/nano cap';
COMMENT ON COLUMN symbols.instrument_type IS 'Asset class: equity, ETF, index, futures, options, etc.';
