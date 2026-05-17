-- ============================================================
-- Materialized View: mv_top_movers
-- Top gainers, losers, and high volume stocks for the latest day
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_top_movers AS
WITH latest_date AS (
    SELECT MAX(date) AS max_date FROM market_data_1d
),
daily_moves AS (
    SELECT
        s.id                AS symbol_id,
        s.ticker,
        s.name              AS symbol_name,
        s.sector,
        s.market_cap_category,
        e.code              AS exchange_code,
        d.close             AS current_price,
        d.open,
        d.high,
        d.low,
        d.volume,
        d.vwap,
        d.delivery_pct,
        d.date,
        COALESCE(prev.close, d.open) AS prev_close,
        d.close - COALESCE(prev.close, d.open) AS price_change,
        CASE
            WHEN COALESCE(prev.close, d.open) > 0
            THEN ROUND(((d.close - COALESCE(prev.close, d.open)) / COALESCE(prev.close, d.open) * 100)::NUMERIC, 2)
            ELSE 0
        END AS change_pct,
        vol20.avg_20d_volume,
        CASE WHEN vol20.avg_20d_volume > 0 THEN ROUND((d.volume::NUMERIC / vol20.avg_20d_volume), 2) ELSE NULL END AS volume_spike_ratio,
        fr.pe_ratio,
        fr.market_cap_approx
    FROM symbols s
    JOIN exchanges e ON s.exchange_id = e.id
    JOIN market_data_1d d ON d.symbol_id = s.id
    JOIN latest_date ON d.date = latest_date.max_date
    LEFT JOIN LATERAL (
        SELECT close FROM market_data_1d pd WHERE pd.symbol_id = s.id AND pd.date < d.date ORDER BY pd.date DESC LIMIT 1
    ) prev ON TRUE
    LEFT JOIN LATERAL (
        SELECT AVG(volume) AS avg_20d_volume FROM market_data_1d vd
        WHERE vd.symbol_id = s.id AND vd.date BETWEEN d.date - INTERVAL '20 days' AND d.date - INTERVAL '1 day'
    ) vol20 ON TRUE
    LEFT JOIN LATERAL (
        SELECT fr2.pe_ratio, (fr2.pe_ratio * (SELECT close FROM market_data_1d l WHERE l.symbol_id = s.id ORDER BY l.date DESC LIMIT 1)) AS market_cap_approx
        FROM financial_ratios fr2 WHERE fr2.symbol_id = s.id ORDER BY fr2.as_of_date DESC LIMIT 1
    ) fr ON TRUE
    WHERE s.is_active = TRUE AND s.instrument_type = 'equity'
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY exchange_code ORDER BY change_pct DESC) AS gainer_rank,
        RANK() OVER (PARTITION BY exchange_code ORDER BY change_pct ASC)  AS loser_rank,
        RANK() OVER (PARTITION BY exchange_code ORDER BY volume DESC)     AS volume_rank,
        RANK() OVER (PARTITION BY exchange_code ORDER BY COALESCE(volume_spike_ratio,0) DESC) AS spike_rank
    FROM daily_moves
)
SELECT * FROM ranked
WITH DATA;

CREATE UNIQUE INDEX IF NOT EXISTS mv_top_movers_pk
    ON mv_top_movers (symbol_id, date);

CREATE INDEX IF NOT EXISTS mv_top_movers_gainer_rank
    ON mv_top_movers (exchange_code, gainer_rank);

CREATE INDEX IF NOT EXISTS mv_top_movers_loser_rank
    ON mv_top_movers (exchange_code, loser_rank);

CREATE INDEX IF NOT EXISTS mv_top_movers_volume_rank
    ON mv_top_movers (exchange_code, volume_rank);

COMMENT ON MATERIALIZED VIEW mv_top_movers IS 'Top gainers, losers and volume movers for the latest trading day; refresh after market close';
