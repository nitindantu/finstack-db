-- ============================================================
-- Migration: 001_create_schema
-- Domain: screenerx (stock screener platform)
-- Requires: shared schema to be created first
-- ============================================================

CREATE SCHEMA IF NOT EXISTS screenerx;

-- Market data
\i screenerx/postgres/ddl/014_exchanges.sql
\i screenerx/postgres/ddl/015_symbols.sql
\i screenerx/postgres/ddl/016_instrument_master.sql
\i screenerx/postgres/ddl/017_market_data_ticks.sql
\i screenerx/postgres/ddl/018_market_data_ohlcv.sql
\i screenerx/postgres/ddl/019_order_books.sql
\i screenerx/postgres/ddl/020_corporate_actions.sql
\i screenerx/postgres/ddl/021_dividends.sql
\i screenerx/postgres/ddl/022_splits.sql
\i screenerx/postgres/ddl/023_earnings.sql
\i screenerx/postgres/ddl/024_economic_events.sql
\i screenerx/postgres/ddl/025_news_articles.sql
\i screenerx/postgres/ddl/026_sentiment_data.sql

-- Fundamentals
\i screenerx/postgres/ddl/027_companies.sql
\i screenerx/postgres/ddl/028_balance_sheets.sql
\i screenerx/postgres/ddl/029_income_statements.sql
\i screenerx/postgres/ddl/030_cash_flows.sql
\i screenerx/postgres/ddl/031_financial_ratios.sql
\i screenerx/postgres/ddl/032_shareholding_patterns.sql
\i screenerx/postgres/ddl/033_mutual_fund_holdings.sql
\i screenerx/postgres/ddl/034_institutional_holdings.sql
\i screenerx/postgres/ddl/035_analyst_ratings.sql

-- Screener
\i screenerx/postgres/ddl/036_screener_templates.sql
\i screenerx/postgres/ddl/037_screener_filters.sql
\i screenerx/postgres/ddl/038_saved_screeners.sql
\i screenerx/postgres/ddl/039_screener_results_cache.sql
\i screenerx/postgres/ddl/040_screener_executions.sql
\i screenerx/postgres/ddl/041_custom_formulas.sql

-- Portfolio
\i screenerx/postgres/ddl/042_portfolios.sql
\i screenerx/postgres/ddl/043_portfolio_positions.sql
\i screenerx/postgres/ddl/044_portfolio_transactions.sql
\i screenerx/postgres/ddl/045_portfolio_snapshots.sql
\i screenerx/postgres/ddl/046_portfolio_performance.sql

-- Watchlists & Goals
\i screenerx/postgres/ddl/047_watchlists.sql
\i screenerx/postgres/ddl/048_watchlist_items.sql
\i screenerx/postgres/ddl/049_goals.sql
\i screenerx/postgres/ddl/050_rebalancing_rules.sql

-- Alerts & Events
\i screenerx/postgres/ddl/073_alerts.sql
\i screenerx/postgres/ddl/074_alert_events.sql
\i screenerx/postgres/ddl/075_event_store.sql
\i screenerx/postgres/ddl/076_websocket_sessions.sql

-- Analytics
\i screenerx/postgres/ddl/077_kpi_metrics.sql
\i screenerx/postgres/ddl/078_user_activity.sql
\i screenerx/postgres/ddl/079_search_logs.sql

-- Indexes
\i screenerx/postgres/indexes/idx_symbols.sql
\i screenerx/postgres/indexes/idx_market_data.sql
\i screenerx/postgres/indexes/idx_fundamentals.sql
\i screenerx/postgres/indexes/idx_screener.sql
\i screenerx/postgres/indexes/idx_portfolio.sql
\i screenerx/postgres/indexes/idx_alerts_events.sql

-- Functions
\i screenerx/postgres/functions/portfolio_value_function.sql
\i screenerx/postgres/functions/screener_execute_function.sql

-- Triggers
\i screenerx/postgres/triggers/portfolio_trigger.sql
\i screenerx/postgres/triggers/alert_trigger.sql

-- Views
\i screenerx/postgres/views/v_active_alerts.sql
\i screenerx/postgres/views/v_portfolio_holdings.sql
\i screenerx/postgres/views/v_stock_overview.sql

-- Materialized Views
\i screenerx/postgres/materialized_views/mv_portfolio_summary.sql
\i screenerx/postgres/materialized_views/mv_sector_performance.sql
\i screenerx/postgres/materialized_views/mv_stock_daily_summary.sql
\i screenerx/postgres/materialized_views/mv_top_movers.sql

-- TimescaleDB hypertables (run after tables exist)
\i screenerx/timescaledb/hypertables/create_hypertables.sql
\i screenerx/timescaledb/compression/compression_policies.sql
\i screenerx/timescaledb/retention/retention_policies.sql
\i screenerx/timescaledb/continuous_aggregates/cagg_market_data_5m.sql
\i screenerx/timescaledb/continuous_aggregates/cagg_market_data_1h.sql
\i screenerx/timescaledb/continuous_aggregates/cagg_daily_volume_profile.sql

-- Seed data
\i screenerx/postgres/dml/seed_002_exchanges.sql
\i screenerx/postgres/dml/seed_003_symbols.sql
\i screenerx/postgres/dml/seed_004_companies.sql
\i screenerx/postgres/dml/seed_005_market_data.sql
\i screenerx/postgres/dml/seed_006_portfolios.sql
\i screenerx/postgres/dml/seed_007_screeners.sql
