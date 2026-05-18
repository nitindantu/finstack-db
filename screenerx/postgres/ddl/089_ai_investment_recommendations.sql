CREATE TABLE IF NOT EXISTS screenerx.ai_investment_recommendations (
    id                      UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL,
    symbol_id               UUID,
    instrument_type         VARCHAR(20) NOT NULL DEFAULT 'stock'
                                CHECK (instrument_type IN ('stock','etf','mutual_fund','bond','sgb','reit')),
    recommendation_type     VARCHAR(10) NOT NULL DEFAULT 'buy'
                                CHECK (recommendation_type IN ('buy','sell','hold','avoid')),
    conviction_level        VARCHAR(10) NOT NULL DEFAULT 'medium'
                                CHECK (conviction_level IN ('high','medium','low')),
    target_price            DECIMAL(12,2),
    time_horizon            VARCHAR(50),
    factor_scores           JSONB NOT NULL DEFAULT '{}',
    reasoning               TEXT,
    ai_confidence           DECIMAL(3,2),
    risk_warnings           JSONB NOT NULL DEFAULT '[]',
    sebi_disclaimer         TEXT,
    is_personalized         BOOLEAN NOT NULL DEFAULT TRUE,
    based_on_risk_profile   VARCHAR(30),
    expires_at              TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ai_investment_recommendations_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ai_investment_rec_user ON screenerx.ai_investment_recommendations (user_id, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_investment_rec_type ON screenerx.ai_investment_recommendations (instrument_type, conviction_level);
