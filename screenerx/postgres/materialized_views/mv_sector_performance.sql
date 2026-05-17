-- ============================================================
-- Materialized View: mv_sector_performance
-- Sector-level aggregates for the latest trading day
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sector_performance AS
WITH latest_date AS (
    SELECT MAX(date) AS max_date FROM market_data_1d
),
latest_prices AS (
    SELECT
        d.symbol_id,
        d.close,
        d.volume,
        d.date,
        COALESCE(prev_d.close, d.open) AS prev_close
    FROM market_data_1d d
    JOIN latest_date ON d.date = latest_date.max_date
    LEFT JOIN LATERAL (
        SELECT close FROM market_data_1d pd
        WHERE pd.symbol_id = d.symbol_id AND pd.date < d.date
        ORDER BY pd.date DESC LIMIT 1
    ) prev_d ON TRUE
)
SELECT
    s.sector,
    e.code                                              AS exchange_code,
    COUNT(DISTINCT s.id)                                AS stock_count,
    ROUND(AVG(
        CASE WHEN lp.prev_close > 0
             THEN ((lp.close - lp.prev_close) / lp.prev_close) * 100
             ELSE 0 END
    )::NUMERIC, 4)                                      AS avg_change_pct,
    SUM(lp.volume)                                      AS total_volume,
    COUNT(CASE WHEN lp.close > lp.prev_close THEN 1 END) AS advancers,
    COUNT(CASE WHEN lp.close < lp.prev_close THEN 1 END) AS decliners,
    COUNT(CASE WHEN lp.close = lp.prev_close THEN 1 END) AS unchanged,
    ROUND(AVG(fr.pe_ratio)::NUMERIC, 2)                 AS avg_pe_ratio,
    ROUND(AVG(fr.pb_ratio)::NUMERIC, 2)                 AS avg_pb_ratio,
    ROUND(AVG(fr.roe)::NUMERIC, 4)                      AS avg_roe,
    MAX(ld.max_date)                                    AS as_of_date
FROM symbols s
JOIN exchanges e ON s.exchange_id = e.id
JOIN latest_prices lp ON lp.symbol_id = s.id
LEFT JOIN LATERAL (
    SELECT pe_ratio, pb_ratio, roe
    FROM financial_ratios fr2 WHERE fr2.symbol_id = s.id ORDER BY fr2.as_of_date DESC LIMIT 1
) fr ON TRUE
CROSS JOIN latest_date ld
WHERE s.is_active = TRUE AND s.sector IS NOT NULL
GROUP BY s.sector, e.code
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS mv_sector_performance_pk
    ON mv_sector_performance (sector, exchange_code);

CREATE INDEX IF NOT EXISTS mv_sector_performance_change_pct
    ON mv_sector_performance (avg_change_pct DESC);

COMMENT ON MATERIALIZED VIEW mv_sector_performance IS 'Sector-level market breadth and valuation aggregates; refresh after market close';
