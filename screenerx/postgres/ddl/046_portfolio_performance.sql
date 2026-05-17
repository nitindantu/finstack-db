-- ============================================================
-- Table: portfolio_performance
-- Domain: Portfolio (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.portfolio_performance (
    portfolio_id        UUID            NOT NULL,
    date                DATE            NOT NULL,
    nav                 NUMERIC(18,6)   NOT NULL CHECK (nav > 0),
    daily_return        NUMERIC(10,6),
    cumulative_return   NUMERIC(10,6),
    benchmark_return    NUMERIC(10,6),
    alpha               NUMERIC(10,6),
    beta                NUMERIC(10,6),
    sharpe_ratio        NUMERIC(10,6),
    sortino_ratio       NUMERIC(10,6),
    max_drawdown        NUMERIC(10,6),
    volatility          NUMERIC(10,6)   CHECK (volatility IS NULL OR volatility >= 0),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT portfolio_performance_pkey PRIMARY KEY (portfolio_id, date),
    CONSTRAINT portfolio_performance_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE CASCADE
);

COMMENT ON TABLE portfolio_performance IS 'Daily risk-adjusted performance metrics per portfolio; TimescaleDB hypertable';
COMMENT ON COLUMN portfolio_performance.nav IS 'Net Asset Value per unit of the portfolio on this date';
COMMENT ON COLUMN portfolio_performance.alpha IS 'Jensen''s alpha: excess return over benchmark adjusted for beta';
COMMENT ON COLUMN portfolio_performance.beta IS 'Sensitivity of portfolio returns to benchmark movements';
COMMENT ON COLUMN portfolio_performance.sharpe_ratio IS 'Annualised Sharpe ratio (trailing 252 days)';
COMMENT ON COLUMN portfolio_performance.max_drawdown IS 'Maximum peak-to-trough decline up to this date';
