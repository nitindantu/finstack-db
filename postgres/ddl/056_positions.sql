-- ============================================================
-- Table: positions
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS positions (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    broker_account_id   UUID            NOT NULL,
    symbol_id           UUID            NOT NULL,
    product_type        product_type    NOT NULL DEFAULT 'delivery',
    quantity            NUMERIC(18,6)   NOT NULL DEFAULT 0,
    avg_price           NUMERIC(18,6)   NOT NULL DEFAULT 0 CHECK (avg_price >= 0),
    current_price       NUMERIC(18,6)   CHECK (current_price IS NULL OR current_price >= 0),
    pnl                 NUMERIC(20,2)   NOT NULL DEFAULT 0,
    pnl_pct             NUMERIC(10,4),
    overnight_quantity  NUMERIC(18,6)   NOT NULL DEFAULT 0,
    day_quantity        NUMERIC(18,6)   NOT NULL DEFAULT 0,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT positions_pkey PRIMARY KEY (id),
    CONSTRAINT positions_broker_account_fk FOREIGN KEY (broker_account_id) REFERENCES broker_accounts (id) ON DELETE CASCADE,
    CONSTRAINT positions_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE RESTRICT,
    CONSTRAINT positions_broker_symbol_product_unique UNIQUE (broker_account_id, symbol_id, product_type)
);

COMMENT ON TABLE positions IS 'Real-time broker positions synced from the broker API';
COMMENT ON COLUMN positions.overnight_quantity IS 'Quantity carried overnight from the previous session';
COMMENT ON COLUMN positions.day_quantity IS 'Quantity traded intraday in the current session';
