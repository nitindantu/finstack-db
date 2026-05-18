CREATE TABLE IF NOT EXISTS screenerx.financial_goals (
    id                   UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id              UUID NOT NULL,
    portfolio_id         UUID,
    goal_type            VARCHAR(30) NOT NULL DEFAULT 'custom'
                             CHECK (goal_type IN ('retirement','education','house','emergency','vehicle','travel','fire','passive_income','custom')),
    name                 VARCHAR(255) NOT NULL,
    target_amount        DECIMAL(18,2) NOT NULL,
    current_savings      DECIMAL(18,2) NOT NULL DEFAULT 0,
    monthly_contribution DECIMAL(18,2) NOT NULL DEFAULT 0,
    target_date          DATE NOT NULL,
    start_date           DATE NOT NULL DEFAULT CURRENT_DATE,
    currency             CHAR(3) NOT NULL DEFAULT 'INR',
    inflation_rate       DECIMAL(5,4) NOT NULL DEFAULT 0.0600,
    expected_return_rate DECIMAL(5,4) NOT NULL DEFAULT 0.1200,
    priority             VARCHAR(10) NOT NULL DEFAULT 'want' CHECK (priority IN ('must','want','nice')),
    monte_carlo_results  JSONB,
    last_simulated_at    TIMESTAMPTZ,
    status               VARCHAR(20) NOT NULL DEFAULT 'active'
                             CHECK (status IN ('active','achieved','at_risk','paused','cancelled')),
    ai_recommendations   JSONB,
    metadata             JSONB NOT NULL DEFAULT '{}',
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT financial_goals_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_financial_goals_user ON screenerx.financial_goals (user_id, status);
CREATE INDEX IF NOT EXISTS idx_financial_goals_target_date ON screenerx.financial_goals (target_date);
