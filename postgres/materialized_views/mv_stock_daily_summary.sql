-- ============================================================
-- Materialized View: mv_stock_daily_summary
-- Daily OHLCV + key ratio summary per stock
-- Refresh: daily after market close
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_stock_daily_summary AS
SELECT
    s.id                            AS symbol_id,
    s.ticker,
    s.name                          AS symbol_name,
    s.sector,
    s.industry,
    s.market_cap_category,
    e.code                          AS exchange_code,
    e.currency,
    d.date,
    d.open,
    d.high,
    d.low,
    d.close,
    d.volume,
    d.adj_close,
    d.vwap,
    d.delivery_volume,
    d.delivery_pct,
    d.trades_count,
    -- Price change
    d.close - COALESCE(prev_d.close, d.open)    AS price_change,
    CASE
        WHEN COALESCE(prev_d.close, d.open) > 0
        THEN ((d.close - COALESCE(prev_d.close, d.open)) / COALESCE(prev_d.close, d.open)) * 100
        ELSE 0
    END                                         AS price_change_pct,
    -- 52-week high/low
    w52.high_52w,
    w52.low_52w,
    CASE WHEN w52.high_52w > 0 THEN (d.close / w52.high_52w) * 100 ELSE NULL END AS pct_of_52w_high,
    -- Financial ratios (latest)
    fr.pe_ratio,
    fr.pb_ratio,
    fr.roe,
    fr.dividend_yield,
    fr.debt_to_equity,
    fr.revenue_growth_yoy,
    -- 20-day average volume
    vol20.avg_volume_20d,
    CASE WHEN vol20.avg_volume_20d > 0 THEN d.volume::NUMERIC / vol20.avg_volume_20d ELSE NULL END AS volume_ratio
FROM symbols s
JOIN exchanges e ON s.exchange_id = e.id
JOIN market_data_1d d ON d.symbol_id = s.id
LEFT JOIN LATERAL (
    SELECT close FROM market_data_1d pd
    WHERE pd.symbol_id = s.id AND pd.date < d.date
    ORDER BY pd.date DESC LIMIT 1
) prev_d ON TRUE
LEFT JOIN LATERAL (
    SELECT MAX(high) AS high_52w, MIN(low) AS low_52w
    FROM market_data_1d wd
    WHERE wd.symbol_id = s.id AND wd.date BETWEEN d.date - INTERVAL '365 days' AND d.date
) w52 ON TRUE
LEFT JOIN LATERAL (
    SELECT AVG(volume) AS avg_volume_20d
    FROM market_data_1d vd
    WHERE vd.symbol_id = s.id AND vd.date BETWEEN d.date - INTERVAL '20 days' AND d.date
) vol20 ON TRUE
LEFT JOIN LATERAL (
    SELECT pe_ratio, pb_ratio, roe, dividend_yield, debt_to_equity, revenue_growth_yoy
    FROM financial_ratios fr2 WHERE fr2.symbol_id = s.id ORDER BY fr2.as_of_date DESC LIMIT 1
) fr ON TRUE
WHERE s.is_active = TRUE
  AND d.date >= CURRENT_DATE - INTERVAL '2 years'
WITH DATA;

-- Indexes on the materialized view
CREATE UNIQUE INDEX IF NOT EXISTS mv_stock_daily_summary_pk
    ON mv_stock_daily_summary (symbol_id, date);

CREATE INDEX IF NOT EXISTS mv_stock_daily_summary_ticker_date
    ON mv_stock_daily_summary (ticker, date DESC);

CREATE INDEX IF NOT EXISTS mv_stock_daily_summary_sector_date
    ON mv_stock_daily_summary (sector, date DESC);

CREATE INDEX IF NOT EXISTS mv_stock_daily_summary_date
    ON mv_stock_daily_summary (date DESC);

COMMENT ON MATERIALIZED VIEW mv_stock_daily_summary IS 'Pre-aggregated daily stock summary with price changes and key ratios; refresh nightly';
