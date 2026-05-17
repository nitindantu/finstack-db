-- ============================================================
-- Indexes: api_keys
-- ============================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_keys_key_hash
    ON api_keys (key_hash)
    WHERE is_active = TRUE AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_keys_user_id
    ON api_keys (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_keys_tenant_id
    ON api_keys (tenant_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_api_keys_expires_at
    ON api_keys (expires_at)
    WHERE is_active = TRUE AND expires_at IS NOT NULL;
