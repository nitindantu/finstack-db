-- ============================================================
-- Table: backtest_results
-- Domain: Strategy & Backtest
-- ============================================================

CREATE TABLE IF NOT EXISTS backtest_results (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    backtest_id             UUID            NOT NULL,
    total_return            NUMERIC(12,6),
    annualized_return       NUMERIC(12,6),
    sharpe_ratio            NUMERIC(10,4),
    sortino_ratio           NUMERIC(10,4),
    max_drawdown            NUMERIC(10,6),
    max_drawdown_duration   INTEGER,
    win_rate                NUMERIC(8,4)    CHECK (win_rate IS NULL OR (win_rate >= 0 AND win_rate <= 1)),
    profit_factor           NUMERIC(10,4)   CHECK (profit_factor IS NULL OR profit_factor >= 0),
    total_trades            INTEGER         CHECK (total_trades IS NULL OR total_trades >= 0),
    avg_trade_duration      NUMERIC(12,4),
    best_trade_pct          NUMERIC(10,4),
    worst_trade_pct         NUMERIC(10,4),
    monthly_returns         JSONB           NOT NULL DEFAULT '{}',
    equity_curve            JSONB           NOT NULL DEFAULT '[]',
    trades                  JSONB           NOT NULL DEFAULT '[]',
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT backtest_results_pkey PRIMARY KEY (id),
    CONSTRAINT backtest_results_backtest_unique UNIQUE (backtest_id),
    CONSTRAINT backtest_results_backtest_fk FOREIGN KEY (backtest_id) REFERENCES backtests (id) ON DELETE CASCADE
);

COMMENT ON TABLE backtest_results IS 'Aggregated performance statistics from a completed backtest run';
COMMENT ON COLUMN backtest_results.equity_curve IS 'JSON array of {date, nav} data points for chart rendering';
COMMENT ON COLUMN backtest_results.trades IS 'JSON array of individual trade records from the backtest';
COMMENT ON COLUMN backtest_results.max_drawdown_duration IS 'Duration of maximum drawdown in calendar days';
