-- ============================================================
-- Continuous Aggregate: cagg_market_data_1h
-- Hierarchical aggregate: 1-hour bars from 5-minute bars
-- Requires cagg_market_data_5m to exist first
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS cagg_market_data_1h
WITH (timescaledb.continuous) AS
SELECT
    symbol_id,
    time_bucket('1 hour', bucket)          AS bucket,
    FIRST(open, bucket)                    AS open,
    MAX(high)                              AS high,
    MIN(low)                               AS low,
    LAST(close, bucket)                    AS close,
    SUM(volume)                            AS volume,
    SUM(vwap * volume) / NULLIF(SUM(volume), 0) AS vwap,
    SUM(trades_count)                      AS trades_count
FROM cagg_market_data_5m
GROUP BY symbol_id, time_bucket('1 hour', bucket)
WITH NO DATA;

-- Refresh policy: update every 5 minutes, covering last 24 hours
SELECT add_continuous_aggregate_policy('cagg_market_data_1h',
    start_offset  => INTERVAL '24 hours',
    end_offset    => INTERVAL '1 hour',
    schedule_interval => INTERVAL '5 minutes',
    if_not_exists => TRUE
);

ALTER MATERIALIZED VIEW cagg_market_data_1h SET (timescaledb.materialized_only = FALSE);

COMMENT ON MATERIALIZED VIEW cagg_market_data_1h IS 'Hierarchical continuous aggregate: 1-hour OHLCV from 5-minute bars; refreshed every 5 minutes';
