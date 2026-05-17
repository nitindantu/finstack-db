-- ============================================================
-- Indexes: users
-- ============================================================

-- Primary lookup by email + tenant (authentication hot path)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email_tenant
    ON users (email, tenant_id)
    WHERE deleted_at IS NULL;

-- Lookup by tenant for admin/ops
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_tenant_id
    ON users (tenant_id)
    WHERE deleted_at IS NULL;

-- Filter by status and plan
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_status
    ON users (status)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_plan_type
    ON users (plan_type)
    WHERE deleted_at IS NULL;

-- Tenant + status composite for admin listings
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_tenant_status
    ON users (tenant_id, status)
    WHERE deleted_at IS NULL;

-- Last login for churn analysis
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_last_login
    ON users (last_login_at DESC NULLS LAST)
    WHERE deleted_at IS NULL;

-- Full-text search on name
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_full_name_trgm
    ON users USING gin (full_name gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- JSONB metadata
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_metadata
    ON users USING gin (metadata);

-- Soft-delete partial
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_deleted_at
    ON users (deleted_at)
    WHERE deleted_at IS NOT NULL;

-- Created at for time-series queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_created_at
    ON users (created_at DESC);
