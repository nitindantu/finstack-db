-- ============================================================
-- View: v_portfolio_holdings
-- Enriches portfolio_positions with symbol/company/price data
-- ============================================================

CREATE OR REPLACE VIEW v_portfolio_holdings AS
SELECT
    pf.id                               AS portfolio_id,
    pf.name                             AS portfolio_name,
    pf.user_id,
    pf.currency                         AS portfolio_currency,
    pp.id                               AS position_id,
    s.id                                AS symbol_id,
    s.ticker,
    s.name                              AS symbol_name,
    s.sector,
    s.industry,
    e.code                              AS exchange_code,
    pp.quantity,
    pp.avg_cost,
    pp.current_price,
    pp.current_value,
    pp.unrealized_pnl,
    pp.unrealized_pnl_pct,
    pp.realized_pnl,
    pp.first_buy_date,
    pp.last_transaction_date,
    -- Weight in portfolio
    CASE WHEN nav.total > 0 THEN pp.current_value / nav.total ELSE 0 END AS portfolio_weight_pct,
    -- Latest day's P&L (close - prev_close * quantity)
    COALESCE(dp.close - prev_dp.close, 0) * pp.quantity                  AS day_pnl,
    dp.date                             AS price_date,
    fr.pe_ratio,
    fr.pb_ratio,
    fr.dividend_yield
FROM portfolios pf
JOIN portfolio_positions pp ON pp.portfolio_id = pf.id AND pp.deleted_at IS NULL AND pp.quantity > 0
JOIN symbols s ON s.id = pp.symbol_id
JOIN exchanges e ON e.id = s.exchange_id
LEFT JOIN LATERAL (
    SELECT close, date FROM market_data_1d d WHERE d.symbol_id = s.id ORDER BY d.date DESC LIMIT 1
) dp ON TRUE
LEFT JOIN LATERAL (
    SELECT close FROM market_data_1d d WHERE d.symbol_id = s.id ORDER BY d.date DESC LIMIT 1 OFFSET 1
) prev_dp ON TRUE
LEFT JOIN LATERAL (
    SELECT pe_ratio, pb_ratio, dividend_yield FROM financial_ratios r WHERE r.symbol_id = s.id ORDER BY r.as_of_date DESC LIMIT 1
) fr ON TRUE
LEFT JOIN LATERAL (
    SELECT SUM(current_value) AS total FROM portfolio_positions p2 WHERE p2.portfolio_id = pf.id AND p2.deleted_at IS NULL AND p2.quantity > 0
) nav ON TRUE
WHERE pf.deleted_at IS NULL AND pf.is_active = TRUE;

COMMENT ON VIEW v_portfolio_holdings IS 'Portfolio positions enriched with live price and financial ratio data';
