-- ============================================================
-- Indexes: audit_logs
-- ============================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_tenant_id
    ON audit_logs (tenant_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_user_id
    ON audit_logs (user_id, created_at DESC)
    WHERE user_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_resource
    ON audit_logs (resource_type, resource_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_action
    ON audit_logs (action, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_created_at
    ON audit_logs (created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_old_values
    ON audit_logs USING gin (old_values);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_logs_new_values
    ON audit_logs USING gin (new_values);
