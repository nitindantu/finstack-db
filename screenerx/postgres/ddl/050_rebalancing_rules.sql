-- ============================================================
-- Table: rebalancing_rules
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.rebalancing_rules (
    id                      UUID                    NOT NULL DEFAULT gen_random_uuid(),
    portfolio_id            UUID                    NOT NULL,
    rule_type               rebalancing_rule_type   NOT NULL DEFAULT 'target_weight',
    allocations             JSONB                   NOT NULL DEFAULT '{}',
    threshold_pct           NUMERIC(6,3)            CHECK (threshold_pct IS NULL OR (threshold_pct > 0 AND threshold_pct <= 100)),
    rebalance_frequency     VARCHAR(50)             CHECK (rebalance_frequency IN ('daily','weekly','monthly','quarterly','annually')),
    last_rebalanced_at      TIMESTAMPTZ,
    is_active               BOOLEAN                 NOT NULL DEFAULT TRUE,
    metadata                JSONB                   NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT rebalancing_rules_pkey PRIMARY KEY (id),
    CONSTRAINT rebalancing_rules_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE CASCADE
);

COMMENT ON TABLE rebalancing_rules IS 'Automatic rebalancing rules for portfolio target allocations';
COMMENT ON COLUMN rebalancing_rules.allocations IS 'JSON map of {symbol_id or sector: target_weight_pct}';
COMMENT ON COLUMN rebalancing_rules.threshold_pct IS 'Trigger rebalance if any position drifts by more than this pct';
COMMENT ON COLUMN rebalancing_rules.rebalance_frequency IS 'Calendar-based rebalance schedule (for calendar rule type)';
