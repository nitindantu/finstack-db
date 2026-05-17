-- ============================================================
-- Table: training_runs
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS training_runs (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    model_id            UUID        NOT NULL,
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    status              run_status  NOT NULL DEFAULT 'pending',
    training_config     JSONB       NOT NULL DEFAULT '{}',
    metrics             JSONB       NOT NULL DEFAULT '{}',
    artifact_path       TEXT,
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT training_runs_pkey PRIMARY KEY (id),
    CONSTRAINT training_runs_model_fk FOREIGN KEY (model_id) REFERENCES ml_models (id) ON DELETE CASCADE,
    CONSTRAINT training_runs_completed_after_started CHECK (
        completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at
    )
);

COMMENT ON TABLE training_runs IS 'Individual model training job runs with configuration and outcome metrics';
COMMENT ON COLUMN training_runs.training_config IS 'JSON: hyperparameters, data splits, augmentation settings used for this run';
COMMENT ON COLUMN training_runs.metrics IS 'JSON: training and validation metrics captured at end of training';
