-- ============================================================
-- Indexes: screener_templates, filters, results_cache
-- ============================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_templates_user_id
    ON screener_templates (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_templates_public
    ON screener_templates (is_public, use_count DESC)
    WHERE is_public = TRUE AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_templates_system
    ON screener_templates (is_system)
    WHERE is_system = TRUE;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_templates_category
    ON screener_templates (category)
    WHERE category IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_templates_filters
    ON screener_templates USING gin (filters);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_filters_template_id
    ON screener_filters (screener_template_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_results_cache_hash
    ON screener_results_cache (screener_hash);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_results_cache_expires
    ON screener_results_cache (expires_at);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_executions_user_id
    ON screener_executions (user_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_screener_executions_screener_id
    ON screener_executions (screener_id)
    WHERE screener_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_custom_formulas_user_id
    ON custom_formulas (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_custom_formulas_public
    ON custom_formulas (is_public)
    WHERE is_public = TRUE AND deleted_at IS NULL;
