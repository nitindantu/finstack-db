-- ============================================================
-- Table: feature_store
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.feature_store (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    name                    VARCHAR(200) NOT NULL,
    feature_type            VARCHAR(50) NOT NULL CHECK (feature_type IN ('numeric','categorical','boolean','text','embedding','timeseries')),
    description             TEXT,
    computation_logic       TEXT,
    dependencies            TEXT[]      NOT NULL DEFAULT '{}',
    update_frequency        VARCHAR(50) CHECK (update_frequency IN ('realtime','1m','5m','15m','1h','1d','weekly','monthly')),
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT feature_store_pkey PRIMARY KEY (id),
    CONSTRAINT feature_store_name_unique UNIQUE (name)
);

COMMENT ON TABLE feature_store IS 'Feature registry for the ML pipeline; defines how each feature is computed';
COMMENT ON COLUMN feature_store.computation_logic IS 'SQL or Python pseudocode describing how to compute this feature';
COMMENT ON COLUMN feature_store.dependencies IS 'Array of other feature names this feature depends on';
