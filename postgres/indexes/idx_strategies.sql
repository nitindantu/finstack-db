-- ============================================================
-- Indexes: strategies, backtests, alpha_signals
-- ============================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_strategies_user_id
    ON strategies (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_strategies_public
    ON strategies (is_public)
    WHERE is_public = TRUE AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_strategies_type
    ON strategies (strategy_type)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_backtests_strategy_id
    ON backtests (strategy_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_backtests_user_id
    ON backtests (user_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_backtests_status
    ON backtests (status)
    WHERE status IN ('queued','running');

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alpha_signals_symbol_date
    ON alpha_signals (symbol_id, signal_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alpha_signals_strategy_date
    ON alpha_signals (strategy_id, signal_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alpha_signals_type_date
    ON alpha_signals (signal_type, signal_date DESC);
