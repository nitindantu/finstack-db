-- ============================================================
-- Table: instrument_master
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS instrument_master (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    symbol_id               UUID            NOT NULL,
    lot_size                INTEGER         NOT NULL DEFAULT 1 CHECK (lot_size > 0),
    tick_size               NUMERIC(12,6)   NOT NULL DEFAULT 0.05 CHECK (tick_size > 0),
    face_value              NUMERIC(12,2)   NOT NULL DEFAULT 10.00 CHECK (face_value > 0),
    issued_capital          NUMERIC(20,2),
    paid_up_capital         NUMERIC(20,2),
    listing_status          VARCHAR(50)     NOT NULL DEFAULT 'listed' CHECK (listing_status IN ('listed','suspended','delisted','unlisted')),
    derivatives_available   BOOLEAN         NOT NULL DEFAULT FALSE,
    margin_pct              NUMERIC(5,2)    CHECK (margin_pct IS NULL OR (margin_pct >= 0 AND margin_pct <= 100)),
    circuit_limits          JSONB           NOT NULL DEFAULT '{"upper_pct":20,"lower_pct":20}',
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT instrument_master_pkey PRIMARY KEY (id),
    CONSTRAINT instrument_master_symbol_unique UNIQUE (symbol_id),
    CONSTRAINT instrument_master_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE instrument_master IS 'Exchange-specific trading parameters for each listed instrument';
COMMENT ON COLUMN instrument_master.lot_size IS 'Minimum order quantity (1 for equities, larger for futures)';
COMMENT ON COLUMN instrument_master.tick_size IS 'Minimum price movement in exchange currency';
COMMENT ON COLUMN instrument_master.face_value IS 'Nominal / par value per share';
COMMENT ON COLUMN instrument_master.circuit_limits IS 'JSON with upper_pct and lower_pct circuit breaker thresholds';
COMMENT ON COLUMN instrument_master.margin_pct IS 'SEBI/exchange prescribed initial margin percentage';
