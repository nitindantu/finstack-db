-- ============================================================
-- Migration 004: Seed Data
-- Run AFTER migrations 001 and 002
-- Inserts reference data required for the application to function
-- ============================================================

\echo 'Migration 004: Seeding users...'
\i ../dml/seed_001_users.sql

\echo 'Migration 004: Seeding exchanges...'
\i ../dml/seed_002_exchanges.sql

\echo 'Migration 004: Seeding symbols...'
\i ../dml/seed_003_symbols.sql

\echo 'Migration 004: Seeding companies...'
\i ../dml/seed_004_companies.sql

\echo 'Migration 004: Seeding market data (OHLCV, dividends, earnings, ratios)...'
\i ../dml/seed_005_market_data.sql

\echo 'Migration 004: Seeding portfolio data...'
\i ../dml/seed_006_portfolios.sql

\echo 'Migration 004: Seeding screeners, roles, permissions...'
\i ../dml/seed_007_screeners.sql

\echo 'Migration 004: Seeding trading data (brokers, strategies, backtests, alerts)...'
\i ../dml/seed_008_trading.sql

\echo 'Migration 004: Refreshing materialized views...'
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stock_daily_summary;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_sector_performance;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_movers;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_portfolio_summary;

\echo 'Migration 004: COMPLETE'
