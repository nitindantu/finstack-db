-- ============================================================
-- Indexes: portfolios, positions, transactions, watchlists
-- ============================================================

-- portfolios
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolios_user_id
    ON portfolios (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolios_tenant_id
    ON portfolios (tenant_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolios_user_active
    ON portfolios (user_id, is_active)
    WHERE deleted_at IS NULL AND is_active = TRUE;

-- portfolio_positions
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolio_positions_portfolio_id
    ON portfolio_positions (portfolio_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolio_positions_symbol_id
    ON portfolio_positions (symbol_id);

-- portfolio_transactions
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolio_transactions_portfolio_id
    ON portfolio_transactions (portfolio_id, transaction_date DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolio_transactions_symbol_id
    ON portfolio_transactions (symbol_id, transaction_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_portfolio_transactions_date
    ON portfolio_transactions (transaction_date DESC);

-- watchlists
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_watchlists_user_id
    ON watchlists (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_watchlists_user_default
    ON watchlists (user_id)
    WHERE is_default = TRUE AND deleted_at IS NULL;

-- watchlist_items
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_watchlist_items_watchlist_id
    ON watchlist_items (watchlist_id, sort_order);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_watchlist_items_symbol_id
    ON watchlist_items (symbol_id);

-- goals
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_goals_user_id
    ON goals (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_goals_portfolio_id
    ON goals (portfolio_id)
    WHERE portfolio_id IS NOT NULL AND deleted_at IS NULL;
