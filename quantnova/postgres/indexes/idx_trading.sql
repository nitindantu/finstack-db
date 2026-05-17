-- ============================================================
-- Indexes: orders, fills, executions, positions
-- ============================================================

-- orders
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_user_id
    ON orders (user_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_portfolio_id
    ON orders (portfolio_id, created_at DESC)
    WHERE portfolio_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_broker_account_id
    ON orders (broker_account_id)
    WHERE broker_account_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_symbol_id
    ON orders (symbol_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_status
    ON orders (status, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_open_pending
    ON orders (user_id, symbol_id)
    WHERE status IN ('pending','open','partial') AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_broker_order_id
    ON orders (broker_order_id)
    WHERE broker_order_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_metadata
    ON orders USING gin (metadata);

-- order_fills
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_fills_order_id
    ON order_fills (order_id, fill_time DESC);

-- executions
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_executions_order_id
    ON executions (order_id, execution_time DESC);

-- positions
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_positions_broker_account_id
    ON positions (broker_account_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_positions_symbol_id
    ON positions (symbol_id);

-- risk_limits
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_risk_limits_user_id
    ON risk_limits (user_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_risk_limits_portfolio_id
    ON risk_limits (portfolio_id)
    WHERE portfolio_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_risk_limits_breached
    ON risk_limits (user_id)
    WHERE is_breached = TRUE;

-- pnl_snapshots
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_pnl_snapshots_portfolio_ts
    ON pnl_snapshots (portfolio_id, timestamp DESC);
