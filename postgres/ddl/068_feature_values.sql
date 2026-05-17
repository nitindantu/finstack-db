-- ============================================================
-- Table: feature_values
-- Domain: AI/ML (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS feature_values (
    symbol_id       UUID            NOT NULL,
    feature_id      UUID            NOT NULL,
    as_of_date      DATE            NOT NULL,
    value_numeric   NUMERIC(20,8),
    value_text      TEXT,
    value_jsonb     JSONB,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT feature_values_pkey PRIMARY KEY (symbol_id, feature_id, as_of_date),
    CONSTRAINT feature_values_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    CONSTRAINT feature_values_feature_fk FOREIGN KEY (feature_id) REFERENCES feature_store (id) ON DELETE CASCADE
);

COMMENT ON TABLE feature_values IS 'Historical feature values per symbol per date; TimescaleDB hypertable on as_of_date';
COMMENT ON COLUMN feature_values.value_numeric IS 'Numeric feature value';
COMMENT ON COLUMN feature_values.value_text IS 'Categorical or text feature value';
COMMENT ON COLUMN feature_values.value_jsonb IS 'Complex features (embeddings, arrays) stored as JSONB';
