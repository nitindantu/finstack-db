-- ============================================================
-- Continuous Aggregate: cagg_market_data_5m
-- Aggregates tick data into 5-minute OHLCV bars
-- Materialized in real-time as ticks arrive
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS cagg_market_data_5m
WITH (timescaledb.continuous) AS
SELECT
    symbol_id,
    time_bucket('5 minutes', timestamp)    AS bucket,
    FIRST(price, timestamp)                AS open,
    MAX(price)                             AS high,
    MIN(price)                             AS low,
    LAST(price, timestamp)                 AS close,
    SUM(volume)                            AS volume,
    SUM(price * volume) / NULLIF(SUM(volume), 0) AS vwap,
    COUNT(*)                               AS trades_count
FROM market_data_ticks
GROUP BY symbol_id, time_bucket('5 minutes', timestamp)
WITH NO DATA;

-- Refresh policy: update every 1 minute, covering last 2 hours
SELECT add_continuous_aggregate_policy('cagg_market_data_5m',
    start_offset  => INTERVAL '2 hours',
    end_offset    => INTERVAL '5 minutes',
    schedule_interval => INTERVAL '1 minute',
    if_not_exists => TRUE
);

-- Enable real-time aggregation so queries see data from current open chunk
ALTER MATERIALIZED VIEW cagg_market_data_5m SET (timescaledb.materialized_only = FALSE);

COMMENT ON MATERIALIZED VIEW cagg_market_data_5m IS 'Continuous aggregate: 5-minute OHLCV from raw ticks; auto-refreshed every 1 minute';
