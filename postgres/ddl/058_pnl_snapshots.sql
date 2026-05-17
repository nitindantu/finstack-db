-- ============================================================
-- Table: pnl_snapshots
-- Domain: Trading (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS pnl_snapshots (
    portfolio_id        UUID            NOT NULL,
    broker_account_id   UUID,
    timestamp           TIMESTAMPTZ     NOT NULL,
    realized_pnl        NUMERIC(20,2)   NOT NULL DEFAULT 0,
    unrealized_pnl      NUMERIC(20,2)   NOT NULL DEFAULT 0,
    day_pnl             NUMERIC(20,2)   NOT NULL DEFAULT 0,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT pnl_snapshots_pkey PRIMARY KEY (portfolio_id, timestamp),
    CONSTRAINT pnl_snapshots_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES portfolios (id) ON DELETE CASCADE,
    CONSTRAINT pnl_snapshots_broker_fk FOREIGN KEY (broker_account_id) REFERENCES broker_accounts (id) ON DELETE SET NULL
);

COMMENT ON TABLE pnl_snapshots IS 'Intraday P&L snapshots for live monitoring; TimescaleDB hypertable on timestamp';
