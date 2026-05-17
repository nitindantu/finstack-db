-- ============================================================
-- Table: portfolio_positions
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS portfolio_positions (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    portfolio_id            UUID            NOT NULL,
    symbol_id               UUID            NOT NULL,
    quantity                NUMERIC(18,6)   NOT NULL DEFAULT 0,
    avg_cost                NUMERIC(18,6)   NOT NULL DEFAULT 0 CHECK (avg_cost >= 0),
    current_price           NUMERIC(18,6)   CHECK (current_price IS NULL OR current_price >= 0),
    current_value           NUMERIC(20,2)   CHECK (current_value IS NULL OR current_value >= 0),
    unrealized_pnl          NUMERIC(20,2),
    unrealized_pnl_pct      NUMERIC(10,4),
    realized_pnl            NUMERIC(20,2)   NOT NULL DEFAULT 0,
    first_buy_date          DATE,
    last_transaction_date   DATE,
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT portfolio_positions_pkey PRIMARY KEY (id),
    CONSTRAINT portfolio_positions_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES portfolios (id) ON DELETE CASCADE,
    CONSTRAINT portfolio_positions_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE RESTRICT,
    CONSTRAINT portfolio_positions_portfolio_symbol_unique UNIQUE (portfolio_id, symbol_id)
);

COMMENT ON TABLE portfolio_positions IS 'Current (aggregated) holdings per symbol in a portfolio';
COMMENT ON COLUMN portfolio_positions.quantity IS 'Net quantity held; can be fractional for some instruments';
COMMENT ON COLUMN portfolio_positions.avg_cost IS 'Average cost basis per unit after FIFO/LIFO adjustments';
COMMENT ON COLUMN portfolio_positions.realized_pnl IS 'Total profit/loss crystallised from closed trades for this symbol';
