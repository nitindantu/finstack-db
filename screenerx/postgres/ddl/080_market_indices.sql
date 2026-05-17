-- ============================================================
-- Table: market_indices
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.market_indices (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    symbol          VARCHAR(50)     NOT NULL,
    name            VARCHAR(200)    NOT NULL,
    region          VARCHAR(100)    NOT NULL DEFAULT 'India',
    index_type      VARCHAR(20)     NOT NULL DEFAULT 'domestic' CHECK (index_type IN ('domestic','global','sector','vix')),
    current_value   NUMERIC(18,2)   NOT NULL DEFAULT 0,
    change_value    NUMERIC(18,2)   NOT NULL DEFAULT 0,
    change_pct      NUMERIC(8,4)    NOT NULL DEFAULT 0,
    prev_close      NUMERIC(18,2)   NOT NULL DEFAULT 0,
    open_value      NUMERIC(18,2),
    high_value      NUMERIC(18,2),
    low_value       NUMERIC(18,2),
    sparkline       JSONB           NOT NULL DEFAULT '[]',
    trade_date      DATE            NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT market_indices_pkey PRIMARY KEY (id),
    CONSTRAINT market_indices_symbol_date_uq UNIQUE (symbol, trade_date)
);

CREATE INDEX IF NOT EXISTS idx_market_indices_symbol ON screenerx.market_indices (symbol);
CREATE INDEX IF NOT EXISTS idx_market_indices_trade_date ON screenerx.market_indices (trade_date DESC);
CREATE INDEX IF NOT EXISTS idx_market_indices_type ON screenerx.market_indices (index_type);

COMMENT ON TABLE screenerx.market_indices IS 'Snapshot of market index values with sparkline history for dashboard display';
