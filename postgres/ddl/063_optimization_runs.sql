-- ============================================================
-- Table: optimization_runs
-- Domain: Strategy & Backtest
-- ============================================================

CREATE TABLE IF NOT EXISTS optimization_runs (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    strategy_id             UUID            NOT NULL,
    parameter_ranges        JSONB           NOT NULL DEFAULT '{}',
    optimization_metric     VARCHAR(100)    NOT NULL DEFAULT 'sharpe_ratio',
    status                  run_status      NOT NULL DEFAULT 'pending',
    best_parameters         JSONB,
    results                 JSONB           NOT NULL DEFAULT '[]',
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT optimization_runs_pkey PRIMARY KEY (id),
    CONSTRAINT optimization_runs_strategy_fk FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE
);

COMMENT ON TABLE optimization_runs IS 'Grid search / Bayesian optimisation runs for strategy parameter tuning';
COMMENT ON COLUMN optimization_runs.parameter_ranges IS 'JSON map of parameter name to {min, max, step} or [list of values]';
COMMENT ON COLUMN optimization_runs.optimization_metric IS 'Metric to maximise: sharpe_ratio, total_return, win_rate, etc.';
COMMENT ON COLUMN optimization_runs.best_parameters IS 'Parameter set that achieved the best metric value';
COMMENT ON COLUMN optimization_runs.results IS 'JSON array of all evaluated parameter combinations and their scores';
