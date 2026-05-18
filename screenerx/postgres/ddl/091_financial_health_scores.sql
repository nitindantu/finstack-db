CREATE TABLE IF NOT EXISTS screenerx.financial_health_scores (
    id                    UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id               UUID NOT NULL,
    overall_score         DECIMAL(5,1) NOT NULL CHECK (overall_score BETWEEN 0 AND 100),
    emergency_fund_score  DECIMAL(5,1),
    debt_score            DECIMAL(5,1),
    insurance_score       DECIMAL(5,1),
    investment_score      DECIMAL(5,1),
    tax_efficiency_score  DECIMAL(5,1),
    goal_progress_score   DECIMAL(5,1),
    score_breakdown       JSONB NOT NULL DEFAULT '{}',
    recommendations       JSONB NOT NULL DEFAULT '[]',
    calculated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    next_review_at        TIMESTAMPTZ,
    CONSTRAINT financial_health_scores_pk PRIMARY KEY (id),
    CONSTRAINT financial_health_scores_user_uq UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_financial_health_user ON screenerx.financial_health_scores (user_id);
