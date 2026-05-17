-- ============================================================
-- Table: drift_detection
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS drift_detection (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    model_id            UUID        NOT NULL,
    detected_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    drift_type          drift_type  NOT NULL,
    drift_score         NUMERIC(8,6) NOT NULL CHECK (drift_score >= 0),
    affected_features   TEXT[]      NOT NULL DEFAULT '{}',
    alert_triggered     BOOLEAN     NOT NULL DEFAULT FALSE,
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT drift_detection_pkey PRIMARY KEY (id),
    CONSTRAINT drift_detection_model_fk FOREIGN KEY (model_id) REFERENCES ml_models (id) ON DELETE CASCADE
);

COMMENT ON TABLE drift_detection IS 'Model and data drift detection events for ML model health monitoring';
COMMENT ON COLUMN drift_detection.drift_score IS 'Statistical drift measure (e.g. PSI, KL-divergence) normalised to [0, ∞)';
COMMENT ON COLUMN drift_detection.affected_features IS 'Features with statistically significant drift';
