-- ============================================================
-- Indexes: sessions
-- ============================================================

-- Token validation hot path
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_token_hash
    ON sessions (token_hash)
    WHERE revoked_at IS NULL;

-- All active sessions for a user
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_user_id_active
    ON sessions (user_id, expires_at)
    WHERE revoked_at IS NULL;

-- Device-based lookup
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_device_id
    ON sessions (device_id)
    WHERE revoked_at IS NULL;

-- Expire job
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_sessions_expires_at
    ON sessions (expires_at)
    WHERE revoked_at IS NULL;
