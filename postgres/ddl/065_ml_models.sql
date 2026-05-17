-- ============================================================
-- Table: ml_models
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS ml_models (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    name                VARCHAR(255)    NOT NULL,
    model_type          ml_model_type   NOT NULL,
    description         TEXT,
    input_features      TEXT[]          NOT NULL DEFAULT '{}',
    output_schema       JSONB           NOT NULL DEFAULT '{}',
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT ml_models_pkey PRIMARY KEY (id),
    CONSTRAINT ml_models_name_unique UNIQUE (name)
);

COMMENT ON TABLE ml_models IS 'Catalogue of ML model definitions used for predictions and recommendations';
COMMENT ON COLUMN ml_models.input_features IS 'Array of feature names this model expects as input';
COMMENT ON COLUMN ml_models.output_schema IS 'JSON schema describing the model''s output structure';
