-- ============================================================
-- Table: risk_limits
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.risk_limits (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID            NOT NULL,
    portfolio_id    UUID,
    limit_type      risk_limit_type NOT NULL,
    limit_value     NUMERIC(20,4)   NOT NULL CHECK (limit_value > 0),
    current_value   NUMERIC(20,4)   NOT NULL DEFAULT 0,
    is_breached     BOOLEAN         NOT NULL DEFAULT FALSE,
    breach_action   breach_action   NOT NULL DEFAULT 'alert',
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT risk_limits_pkey PRIMARY KEY (id),
    CONSTRAINT risk_limits_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT risk_limits_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE CASCADE
);

COMMENT ON TABLE risk_limits IS 'Risk guard-rails per user or portfolio with configurable breach actions';
COMMENT ON COLUMN risk_limits.limit_type IS 'Type of risk control: position size, daily loss, drawdown, concentration, VaR';
COMMENT ON COLUMN risk_limits.limit_value IS 'The threshold value; interpretation depends on limit_type (% or INR amount)';
COMMENT ON COLUMN risk_limits.current_value IS 'Latest measured value for this limit, updated by risk engine';
COMMENT ON COLUMN risk_limits.breach_action IS 'What happens when limit is breached: alert only, block new orders, or liquidate';
