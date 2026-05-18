CREATE TABLE IF NOT EXISTS screenerx.portfolio_analyses (
    id                    UUID NOT NULL DEFAULT gen_random_uuid(),
    portfolio_id          UUID NOT NULL,
    analysis_type         VARCHAR(30) NOT NULL DEFAULT 'full'
                              CHECK (analysis_type IN ('optimization','rebalancing','risk','diversification','full')),
    sharpe_ratio          DECIMAL(8,4),
    sortino_ratio         DECIMAL(8,4),
    max_drawdown          DECIMAL(7,4),
    volatility_annual     DECIMAL(7,4),
    beta                  DECIMAL(7,4),
    alpha                 DECIMAL(7,4),
    diversification_score DECIMAL(5,2),
    concentration_risk    JSONB,
    sector_allocation     JSONB,
    asset_class_allocation JSONB,
    correlation_matrix    JSONB,
    factor_exposures      JSONB,
    rebalancing_suggestions JSONB,
    ai_narrative          TEXT,
    confidence_score      DECIMAL(3,2),
    valid_until           TIMESTAMPTZ,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT portfolio_analyses_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_portfolio_analyses_portfolio ON screenerx.portfolio_analyses (portfolio_id, created_at DESC);
