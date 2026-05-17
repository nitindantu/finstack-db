-- ============================================================
-- Table: portfolio_snapshots
-- Domain: Portfolio (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.portfolio_snapshots (
    portfolio_id        UUID            NOT NULL,
    snapshot_date       DATE            NOT NULL,
    total_value         NUMERIC(20,2)   NOT NULL CHECK (total_value >= 0),
    cash_balance        NUMERIC(20,2)   NOT NULL DEFAULT 0,
    invested_value      NUMERIC(20,2)   NOT NULL DEFAULT 0 CHECK (invested_value >= 0),
    unrealized_pnl      NUMERIC(20,2)   NOT NULL DEFAULT 0,
    realized_pnl        NUMERIC(20,2)   NOT NULL DEFAULT 0,
    day_pnl             NUMERIC(20,2)   NOT NULL DEFAULT 0,
    positions_snapshot  JSONB           NOT NULL DEFAULT '[]',
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT portfolio_snapshots_pkey PRIMARY KEY (portfolio_id, snapshot_date),
    CONSTRAINT portfolio_snapshots_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE CASCADE
);

COMMENT ON TABLE portfolio_snapshots IS 'End-of-day portfolio value snapshots; TimescaleDB hypertable on snapshot_date';
COMMENT ON COLUMN portfolio_snapshots.positions_snapshot IS 'JSON array snapshot of all positions at end of day';
COMMENT ON COLUMN portfolio_snapshots.day_pnl IS 'Profit or loss for the day vs previous snapshot';
