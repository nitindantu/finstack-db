-- ============================================================
-- Materialized View: mv_portfolio_summary
-- Per-user portfolio summary across all portfolios
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_portfolio_summary AS
SELECT
    u.id                                        AS user_id,
    u.email,
    u.full_name,
    u.plan_type,
    COUNT(DISTINCT pf.id)                       AS portfolio_count,
    SUM(COALESCE(pos_agg.total_current_value, 0))  AS total_portfolio_value,
    SUM(COALESCE(pos_agg.total_invested,0))     AS total_invested,
    SUM(COALESCE(pos_agg.total_unrealized_pnl,0)) AS total_unrealized_pnl,
    SUM(COALESCE(pos_agg.total_realized_pnl,0)) AS total_realized_pnl,
    CASE
        WHEN SUM(COALESCE(pos_agg.total_invested, 0)) > 0
        THEN ROUND((SUM(COALESCE(pos_agg.total_unrealized_pnl, 0)) / SUM(COALESCE(pos_agg.total_invested, 0)) * 100)::NUMERIC, 2)
        ELSE 0
    END                                         AS overall_unrealized_pnl_pct,
    COUNT(DISTINCT wl.id)                       AS watchlist_count,
    SUM(COALESCE(wl.item_count, 0))             AS total_watchlist_items,
    COUNT(DISTINCT a.id)                        AS active_alert_count,
    NOW()                                       AS last_refreshed_at
FROM users u
LEFT JOIN portfolios pf ON pf.user_id = u.id AND pf.deleted_at IS NULL AND pf.is_active = TRUE
LEFT JOIN LATERAL (
    SELECT
        SUM(pp.current_value)   AS total_current_value,
        SUM(pp.quantity * pp.avg_cost) AS total_invested,
        SUM(pp.unrealized_pnl)  AS total_unrealized_pnl,
        SUM(pp.realized_pnl)    AS total_realized_pnl
    FROM portfolio_positions pp
    WHERE pp.portfolio_id = pf.id AND pp.deleted_at IS NULL AND pp.quantity > 0
) pos_agg ON TRUE
LEFT JOIN watchlists wl ON wl.user_id = u.id AND wl.deleted_at IS NULL
LEFT JOIN alerts a ON a.user_id = u.id AND a.is_active = TRUE AND a.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.email, u.full_name, u.plan_type
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS mv_portfolio_summary_user_id
    ON mv_portfolio_summary (user_id);

CREATE INDEX IF NOT EXISTS mv_portfolio_summary_total_value
    ON mv_portfolio_summary (total_portfolio_value DESC);

COMMENT ON MATERIALIZED VIEW mv_portfolio_summary IS 'Aggregated portfolio health snapshot per user; refresh hourly during market hours';
