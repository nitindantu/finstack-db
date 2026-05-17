-- ============================================================
-- TimescaleDB Compression Policies
-- ============================================================
-- Compress older chunks to reduce storage by 90%+
-- Compressed chunks are still queryable but not writable
-- ============================================================

-- market_data_ticks: high frequency, compress after 7 days
ALTER TABLE market_data_ticks SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('market_data_ticks',
    compress_after  => INTERVAL '7 days',
    if_not_exists   => TRUE
);

-- market_data_1m: compress after 30 days
ALTER TABLE market_data_1m SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('market_data_1m',
    compress_after  => INTERVAL '30 days',
    if_not_exists   => TRUE
);

-- market_data_5m: compress after 30 days
ALTER TABLE market_data_5m SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('market_data_5m',
    compress_after  => INTERVAL '30 days',
    if_not_exists   => TRUE
);

-- market_data_15m: compress after 60 days
ALTER TABLE market_data_15m SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('market_data_15m',
    compress_after  => INTERVAL '60 days',
    if_not_exists   => TRUE
);

-- market_data_1h: compress after 90 days
ALTER TABLE market_data_1h SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('market_data_1h',
    compress_after  => INTERVAL '90 days',
    if_not_exists   => TRUE
);

-- market_data_1d: compress after 1 year (daily bars kept forever)
ALTER TABLE market_data_1d SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'date DESC'
);
SELECT add_compression_policy('market_data_1d',
    compress_after  => INTERVAL '1 year',
    if_not_exists   => TRUE
);

-- order_books: compress after 7 days
ALTER TABLE order_books SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('order_books',
    compress_after  => INTERVAL '7 days',
    if_not_exists   => TRUE
);

-- sentiment_data: compress after 30 days
ALTER TABLE sentiment_data SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'symbol_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('sentiment_data',
    compress_after  => INTERVAL '30 days',
    if_not_exists   => TRUE
);

-- portfolio_snapshots: compress after 90 days
ALTER TABLE portfolio_snapshots SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'portfolio_id',
    timescaledb.compress_orderby   = 'snapshot_date DESC'
);
SELECT add_compression_policy('portfolio_snapshots',
    compress_after  => INTERVAL '90 days',
    if_not_exists   => TRUE
);

-- pnl_snapshots: compress after 30 days
ALTER TABLE pnl_snapshots SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'portfolio_id',
    timescaledb.compress_orderby   = 'timestamp DESC'
);
SELECT add_compression_policy('pnl_snapshots',
    compress_after  => INTERVAL '30 days',
    if_not_exists   => TRUE
);

-- user_activity: compress after 30 days
ALTER TABLE user_activity SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'user_id',
    timescaledb.compress_orderby   = 'created_at DESC'
);
SELECT add_compression_policy('user_activity',
    compress_after  => INTERVAL '30 days',
    if_not_exists   => TRUE
);

-- event_store: compress after 14 days (immutable events)
ALTER TABLE event_store SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'aggregate_type',
    timescaledb.compress_orderby   = 'occurred_at DESC'
);
SELECT add_compression_policy('event_store',
    compress_after  => INTERVAL '14 days',
    if_not_exists   => TRUE
);

-- inference_logs: compress after 14 days
ALTER TABLE inference_logs SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'model_id',
    timescaledb.compress_orderby   = 'predicted_at DESC'
);
SELECT add_compression_policy('inference_logs',
    compress_after  => INTERVAL '14 days',
    if_not_exists   => TRUE
);
