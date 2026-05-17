-- ============================================================
-- Table: inference_logs
-- Domain: AI/ML (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.inference_logs (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    model_id            UUID            NOT NULL,
    symbol_id           UUID            NOT NULL,
    predicted_at        TIMESTAMPTZ     NOT NULL,
    input_features      JSONB           NOT NULL DEFAULT '{}',
    prediction          JSONB           NOT NULL DEFAULT '{}',
    confidence          NUMERIC(6,4)    CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
    latency_ms          INTEGER         CHECK (latency_ms IS NULL OR latency_ms >= 0),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT inference_logs_pkey PRIMARY KEY (id, predicted_at),
    CONSTRAINT inference_logs_model_fk FOREIGN KEY (model_id) REFERENCES quantnova.ml_models (id) ON DELETE CASCADE,
    CONSTRAINT inference_logs_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE inference_logs IS 'ML model inference audit log; TimescaleDB hypertable on predicted_at';
COMMENT ON COLUMN inference_logs.confidence IS 'Model confidence score in [0, 1] for the prediction';
COMMENT ON COLUMN inference_logs.latency_ms IS 'Time taken to generate the prediction in milliseconds';
