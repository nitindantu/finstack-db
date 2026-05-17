-- ============================================================
-- TimescaleDB Hypertable Conversions
-- Run AFTER all DDL files and the timescaledb extension
-- ============================================================

-- market_data_ticks: tick-level trade data (partition by 1 day)
SELECT create_hypertable(
    'market_data_ticks', 'timestamp',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);
SELECT set_chunk_time_interval('market_data_ticks', INTERVAL '1 day');

-- Add space partitioning on symbol_id for parallel scans across multiple symbols
SELECT add_dimension('market_data_ticks', 'symbol_id',
    number_partitions => 16,
    if_not_exists     => TRUE
);

-- market_data_1m: 1-minute OHLCV (partition by 7 days)
SELECT create_hypertable(
    'market_data_1m', 'timestamp',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- market_data_5m: 5-minute OHLCV (partition by 14 days)
SELECT create_hypertable(
    'market_data_5m', 'timestamp',
    chunk_time_interval => INTERVAL '14 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- market_data_15m: 15-minute OHLCV (partition by 30 days)
SELECT create_hypertable(
    'market_data_15m', 'timestamp',
    chunk_time_interval => INTERVAL '30 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- market_data_1h: 1-hour OHLCV (partition by 90 days)
SELECT create_hypertable(
    'market_data_1h', 'timestamp',
    chunk_time_interval => INTERVAL '90 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- market_data_1d: daily data (partition by 1 year)
-- Note: uses 'date' column (DATE type) — TimescaleDB supports DATE columns
SELECT create_hypertable(
    'market_data_1d', 'date',
    chunk_time_interval => INTERVAL '1 year',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- order_books: L2 order book snapshots (partition by 1 day)
SELECT create_hypertable(
    'order_books', 'timestamp',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);
SELECT add_dimension('order_books', 'symbol_id',
    number_partitions => 8,
    if_not_exists     => TRUE
);

-- sentiment_data: NLP sentiment signals (partition by 7 days)
SELECT create_hypertable(
    'sentiment_data', 'timestamp',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- financial_ratios: daily ratio snapshots (partition by 3 months)
SELECT create_hypertable(
    'financial_ratios', 'as_of_date',
    chunk_time_interval => INTERVAL '3 months',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- portfolio_snapshots: end-of-day portfolio values (partition by 3 months)
SELECT create_hypertable(
    'portfolio_snapshots', 'snapshot_date',
    chunk_time_interval => INTERVAL '3 months',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- portfolio_performance: daily performance metrics (partition by 3 months)
SELECT create_hypertable(
    'portfolio_performance', 'date',
    chunk_time_interval => INTERVAL '3 months',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- pnl_snapshots: intraday P&L snapshots (partition by 1 day)
SELECT create_hypertable(
    'pnl_snapshots', 'timestamp',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- alpha_signals: strategy signals (partition by 1 month)
SELECT create_hypertable(
    'alpha_signals', 'signal_date',
    chunk_time_interval => INTERVAL '1 month',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- feature_values: ML feature store history (partition by 3 months)
SELECT create_hypertable(
    'feature_values', 'as_of_date',
    chunk_time_interval => INTERVAL '3 months',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- inference_logs: ML prediction audit (partition by 7 days)
SELECT create_hypertable(
    'inference_logs', 'predicted_at',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- alert_events: triggered alerts log (partition by 14 days)
SELECT create_hypertable(
    'alert_events', 'triggered_at',
    chunk_time_interval => INTERVAL '14 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- event_store: domain event log (partition by 7 days)
SELECT create_hypertable(
    'event_store', 'occurred_at',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- user_activity: behavioural events (partition by 7 days)
SELECT create_hypertable(
    'user_activity', 'created_at',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);

-- kpi_metrics: platform KPIs (partition by 1 month)
SELECT create_hypertable(
    'kpi_metrics', 'metric_date',
    chunk_time_interval => INTERVAL '1 month',
    if_not_exists       => TRUE,
    migrate_data        => TRUE
);
