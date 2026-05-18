CREATE TABLE IF NOT EXISTS screenerx.risk_profiles (
    id                       UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id                  UUID NOT NULL,
    questionnaire_responses  JSONB NOT NULL DEFAULT '{}',
    risk_score               DECIMAL(5,2) NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_category            VARCHAR(30) NOT NULL
                                 CHECK (risk_category IN ('conservative','moderately_conservative','moderate','moderately_aggressive','aggressive')),
    behavioral_biases        JSONB NOT NULL DEFAULT '{}',
    investment_horizon_years INTEGER NOT NULL DEFAULT 5,
    liquidity_needs          VARCHAR(20) DEFAULT 'medium' CHECK (liquidity_needs IN ('high','medium','low')),
    income_stability         VARCHAR(20) DEFAULT 'stable' CHECK (income_stability IN ('stable','variable','unstable')),
    sebi_category_mapping    VARCHAR(50),
    last_assessed_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at               TIMESTAMPTZ,
    version                  INTEGER NOT NULL DEFAULT 1,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT risk_profiles_pk PRIMARY KEY (id),
    CONSTRAINT risk_profiles_user_uq UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_risk_profiles_user ON screenerx.risk_profiles (user_id);
