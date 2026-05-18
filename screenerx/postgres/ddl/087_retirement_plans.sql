CREATE TABLE IF NOT EXISTS screenerx.retirement_plans (
    id                                UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id                           UUID NOT NULL,
    current_age                       INTEGER NOT NULL,
    retirement_age                    INTEGER NOT NULL DEFAULT 60,
    life_expectancy                   INTEGER NOT NULL DEFAULT 85,
    current_corpus                    DECIMAL(18,2) NOT NULL DEFAULT 0,
    monthly_expense_today             DECIMAL(18,2) NOT NULL,
    expected_inflation                DECIMAL(5,4) NOT NULL DEFAULT 0.0600,
    expected_return_pre_retirement    DECIMAL(5,4) NOT NULL DEFAULT 0.1200,
    expected_return_post_retirement   DECIMAL(5,4) NOT NULL DEFAULT 0.0700,
    withdrawal_strategy               VARCHAR(20) NOT NULL DEFAULT 'swr'
                                          CHECK (withdrawal_strategy IN ('swr','bucket','dynamic')),
    safe_withdrawal_rate              DECIMAL(5,4) NOT NULL DEFAULT 0.0400,
    corpus_required                   DECIMAL(18,2),
    monthly_saving_needed             DECIMAL(18,2),
    nps_corpus                        DECIMAL(18,2) NOT NULL DEFAULT 0,
    epf_corpus                        DECIMAL(18,2) NOT NULL DEFAULT 0,
    ppf_corpus                        DECIMAL(18,2) NOT NULL DEFAULT 0,
    simulation_results                JSONB,
    last_calculated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at                        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT retirement_plans_pk PRIMARY KEY (id),
    CONSTRAINT retirement_plans_user_uq UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_retirement_plans_user ON screenerx.retirement_plans (user_id);
