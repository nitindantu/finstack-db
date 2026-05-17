-- ============================================================
-- Table: goals
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.goals (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    name            VARCHAR(255) NOT NULL,
    target_amount   NUMERIC(20,2) NOT NULL CHECK (target_amount > 0),
    current_amount  NUMERIC(20,2) NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
    target_date     DATE        NOT NULL,
    goal_type       goal_type   NOT NULL DEFAULT 'custom',
    status          goal_status NOT NULL DEFAULT 'active',
    portfolio_id    UUID,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT goals_pkey PRIMARY KEY (id),
    CONSTRAINT goals_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT goals_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE SET NULL,
    CONSTRAINT goals_target_date_future CHECK (target_date > CURRENT_DATE OR status IN ('completed','cancelled'))
);

COMMENT ON TABLE goals IS 'Financial goals tracked against a linked portfolio';
COMMENT ON COLUMN goals.current_amount IS 'Current value toward the goal, updated periodically from portfolio NAV';
