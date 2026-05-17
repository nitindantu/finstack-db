-- ============================================================
-- Table: strategies
-- Domain: Strategy & Backtest
-- ============================================================

CREATE TABLE IF NOT EXISTS strategies (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL,
    name                VARCHAR(255)    NOT NULL,
    description         TEXT,
    strategy_type       strategy_type   NOT NULL DEFAULT 'manual',
    universe_filter     JSONB           NOT NULL DEFAULT '{}',
    entry_conditions    JSONB           NOT NULL DEFAULT '[]',
    exit_conditions     JSONB           NOT NULL DEFAULT '[]',
    position_sizing     JSONB           NOT NULL DEFAULT '{}',
    risk_management     JSONB           NOT NULL DEFAULT '{}',
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    is_public           BOOLEAN         NOT NULL DEFAULT FALSE,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT strategies_pkey PRIMARY KEY (id),
    CONSTRAINT strategies_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT strategies_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE strategies IS 'Trading strategy definitions with entry/exit logic and risk parameters';
COMMENT ON COLUMN strategies.universe_filter IS 'JSON filter criteria for the stock universe this strategy trades';
COMMENT ON COLUMN strategies.entry_conditions IS 'JSON array of conditions that trigger trade entry';
COMMENT ON COLUMN strategies.exit_conditions IS 'JSON array of conditions that trigger trade exit';
COMMENT ON COLUMN strategies.position_sizing IS 'JSON: {method: fixed|pct_equity|kelly, size: 10000, max_pct: 5}';
COMMENT ON COLUMN strategies.risk_management IS 'JSON: {stop_loss_pct: 3, take_profit_pct: 10, max_drawdown_pct: 20}';
