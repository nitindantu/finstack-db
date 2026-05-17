-- ============================================================
-- Table: model_versions
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.model_versions (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    model_id                UUID        NOT NULL,
    version                 VARCHAR(20) NOT NULL,
    artifact_path           TEXT        NOT NULL,
    metrics                 JSONB       NOT NULL DEFAULT '{}',
    training_data_info      JSONB       NOT NULL DEFAULT '{}',
    deployed_at             TIMESTAMPTZ,
    deprecated_at           TIMESTAMPTZ,
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT model_versions_pkey PRIMARY KEY (id),
    CONSTRAINT model_versions_model_fk FOREIGN KEY (model_id) REFERENCES quantnova.ml_models (id) ON DELETE CASCADE,
    CONSTRAINT model_versions_model_version_unique UNIQUE (model_id, version)
);

COMMENT ON TABLE model_versions IS 'Versioned ML model artifacts with training metrics and deployment status';
COMMENT ON COLUMN model_versions.artifact_path IS 'S3/GCS path to the serialized model artifact';
COMMENT ON COLUMN model_versions.metrics IS 'JSON: {accuracy, f1, precision, recall, auc, mse, ...}';
COMMENT ON COLUMN model_versions.training_data_info IS 'JSON: {start_date, end_date, num_samples, feature_importances}';
