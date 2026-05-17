-- ============================================================
-- TimescaleDB Data Retention Policies
-- ============================================================
-- Automatically drop old chunks to manage storage growth
-- market_data_ticks: 90 days
-- 1m bars: 1 year
-- 5m/15m bars: 2 years
-- 1h bars: 5 years
-- 1d bars: FOREVER (no retention policy)
-- order_books: 30 days
-- user_activity: 2 years
-- inference_logs: 1 year
-- ============================================================

-- Tick data: 90 days
SELECT add_retention_policy('market_data_ticks',
    drop_after    => INTERVAL '90 days',
    if_not_exists => TRUE
);

-- 1-minute bars: 1 year
SELECT add_retention_policy('market_data_1m',
    drop_after    => INTERVAL '1 year',
    if_not_exists => TRUE
);

-- 5-minute bars: 2 years
SELECT add_retention_policy('market_data_5m',
    drop_after    => INTERVAL '2 years',
    if_not_exists => TRUE
);

-- 15-minute bars: 2 years
SELECT add_retention_policy('market_data_15m',
    drop_after    => INTERVAL '2 years',
    if_not_exists => TRUE
);

-- 1-hour bars: 5 years
SELECT add_retention_policy('market_data_1h',
    drop_after    => INTERVAL '5 years',
    if_not_exists => TRUE
);

-- Daily bars: NO RETENTION (permanent historical data)
-- Do not call add_retention_policy for market_data_1d

-- Order books L2: 30 days
SELECT add_retention_policy('order_books',
    drop_after    => INTERVAL '30 days',
    if_not_exists => TRUE
);

-- Sentiment data: 1 year
SELECT add_retention_policy('sentiment_data',
    drop_after    => INTERVAL '1 year',
    if_not_exists => TRUE
);

-- P&L snapshots (intraday): 90 days
SELECT add_retention_policy('pnl_snapshots',
    drop_after    => INTERVAL '90 days',
    if_not_exists => TRUE
);

-- Alert events: 1 year
SELECT add_retention_policy('alert_events',
    drop_after    => INTERVAL '1 year',
    if_not_exists => TRUE
);

-- User activity: 2 years
SELECT add_retention_policy('user_activity',
    drop_after    => INTERVAL '2 years',
    if_not_exists => TRUE
);

-- Inference logs: 1 year
SELECT add_retention_policy('inference_logs',
    drop_after    => INTERVAL '1 year',
    if_not_exists => TRUE
);

-- Event store: 3 years (regulatory requirement)
SELECT add_retention_policy('event_store',
    drop_after    => INTERVAL '3 years',
    if_not_exists => TRUE
);

-- KPI metrics: 5 years
SELECT add_retention_policy('kpi_metrics',
    drop_after    => INTERVAL '5 years',
    if_not_exists => TRUE
);
