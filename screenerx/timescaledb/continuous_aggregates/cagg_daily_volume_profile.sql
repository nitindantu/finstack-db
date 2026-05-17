-- ============================================================
-- Continuous Aggregate: cagg_daily_volume_profile
-- Volume profile by price level per symbol per day
-- Helps identify support/resistance levels
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS cagg_daily_volume_profile
WITH (timescaledb.continuous) AS
SELECT
    symbol_id,
    time_bucket('1 day', timestamp)                     AS trade_date,
    -- Round price to nearest 0.50 for intraday profile
    ROUND(price * 2) / 2                                AS price_level,
    SUM(volume)                                         AS volume_at_level,
    COUNT(*)                                            AS tick_count,
    AVG(price)                                          AS avg_price_at_level
FROM market_data_ticks
GROUP BY
    symbol_id,
    time_bucket('1 day', timestamp),
    ROUND(price * 2) / 2
WITH NO DATA;

-- Refresh policy: run once a day after market close (at night)
SELECT add_continuous_aggregate_policy('cagg_daily_volume_profile',
    start_offset  => INTERVAL '3 days',
    end_offset    => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day',
    if_not_exists => TRUE
);

COMMENT ON MATERIALIZED VIEW cagg_daily_volume_profile IS 'Daily volume profile (Volume at Price) per symbol; useful for support/resistance analysis';


-- ============================================================
-- Continuous Aggregate: cagg_symbol_daily_stats
-- Daily statistics per symbol: tick count, bid-ask spread, etc.
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS cagg_symbol_daily_stats
WITH (timescaledb.continuous) AS
SELECT
    symbol_id,
    time_bucket('1 day', timestamp)        AS trade_date,
    COUNT(*)                               AS tick_count,
    SUM(volume)                            AS total_volume,
    AVG(price)                             AS avg_price,
    STDDEV(price)                          AS price_stddev,
    MAX(price)                             AS intraday_high,
    MIN(price)                             AS intraday_low,
    FIRST(price, timestamp)                AS open_price,
    LAST(price, timestamp)                 AS close_price,
    AVG(ask - bid)                         AS avg_spread,
    AVG(CASE WHEN ask > 0 AND bid > 0
             THEN (ask - bid) / ((ask + bid) / 2) * 100
             ELSE NULL END)                AS avg_spread_pct
FROM market_data_ticks
WHERE bid IS NOT NULL AND ask IS NOT NULL
GROUP BY symbol_id, time_bucket('1 day', timestamp)
WITH NO DATA;

SELECT add_continuous_aggregate_policy('cagg_symbol_daily_stats',
    start_offset  => INTERVAL '2 days',
    end_offset    => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists => TRUE
);

ALTER MATERIALIZED VIEW cagg_symbol_daily_stats SET (timescaledb.materialized_only = FALSE);

COMMENT ON MATERIALIZED VIEW cagg_symbol_daily_stats IS 'Daily microstructure statistics per symbol: spread, volatility, tick count';
