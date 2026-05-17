-- ============================================================
-- Indexes: ml_models, feature_values, inference_logs,
--          ai_recommendations, drift_detection
-- ============================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_model_versions_model_id
    ON model_versions (model_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_model_versions_deployed
    ON model_versions (model_id, deployed_at DESC)
    WHERE deployed_at IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_feature_values_symbol_date
    ON feature_values (symbol_id, as_of_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_feature_values_feature_date
    ON feature_values (feature_id, as_of_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_training_runs_model_id
    ON training_runs (model_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_training_runs_status
    ON training_runs (status)
    WHERE status IN ('pending','running');

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_inference_logs_model_symbol
    ON inference_logs (model_id, symbol_id, predicted_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ai_recommendations_user_id
    ON ai_recommendations (user_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ai_recommendations_symbol_id
    ON ai_recommendations (symbol_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ai_recommendations_type
    ON ai_recommendations (recommendation_type)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_drift_detection_model_id
    ON drift_detection (model_id, detected_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_drift_detection_alerted
    ON drift_detection (model_id)
    WHERE alert_triggered = TRUE;
