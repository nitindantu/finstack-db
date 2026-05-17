-- ============================================================
-- Table: strategy_versions
-- Domain: Strategy & Backtest
-- ============================================================

CREATE TABLE IF NOT EXISTS strategy_versions (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    strategy_id     UUID        NOT NULL,
    version         INTEGER     NOT NULL CHECK (version > 0),
    code_snapshot   TEXT,
    parameters      JSONB       NOT NULL DEFAULT '{}',
    changelog       TEXT,
    deployed_at     TIMESTAMPTZ,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT strategy_versions_pkey PRIMARY KEY (id),
    CONSTRAINT strategy_versions_strategy_fk FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE,
    CONSTRAINT strategy_versions_strategy_version_unique UNIQUE (strategy_id, version)
);

COMMENT ON TABLE strategy_versions IS 'Immutable version snapshots of strategy code and parameters';
COMMENT ON COLUMN strategy_versions.code_snapshot IS 'Full Python/YAML strategy code at this version';
COMMENT ON COLUMN strategy_versions.parameters IS 'Hyperparameters used in this version';
COMMENT ON COLUMN strategy_versions.deployed_at IS 'When this version was deployed to the live execution engine';
