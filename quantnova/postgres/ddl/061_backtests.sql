-- ============================================================
-- Table: backtests
-- Domain: Strategy & Backtest
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.backtests (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    strategy_id         UUID            NOT NULL,
    user_id             UUID            NOT NULL,
    name                VARCHAR(255)    NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    initial_capital     NUMERIC(20,2)   NOT NULL CHECK (initial_capital > 0),
    commission_rate     NUMERIC(8,6)    NOT NULL DEFAULT 0.0003 CHECK (commission_rate >= 0),
    slippage_rate       NUMERIC(8,6)    NOT NULL DEFAULT 0.0001 CHECK (slippage_rate >= 0),
    status              backtest_status NOT NULL DEFAULT 'queued',
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT backtests_pkey PRIMARY KEY (id),
    CONSTRAINT backtests_strategy_fk FOREIGN KEY (strategy_id) REFERENCES quantnova.strategies (id) ON DELETE CASCADE,
    CONSTRAINT backtests_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT backtests_date_range_check CHECK (end_date > start_date)
);

COMMENT ON TABLE backtests IS 'Backtest run configurations for a strategy over a historical period';
COMMENT ON COLUMN backtests.commission_rate IS 'Per-trade commission as decimal fraction (e.g. 0.0003 = 3bps)';
COMMENT ON COLUMN backtests.slippage_rate IS 'Assumed slippage per trade as decimal fraction';
