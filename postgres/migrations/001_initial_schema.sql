-- ============================================================
-- Migration 001: Initial Schema
-- Creates all extensions, enums, and tables
-- ============================================================
-- Run order matters: extensions → enums → tables (by FK dependency)
-- ============================================================

\echo 'Migration 001: Installing extensions...'
\i ../ddl/000_extensions.sql

\echo 'Migration 001: Creating enum types...'
\i ../ddl/000_enums.sql

-- USER & AUTH DOMAIN (no foreign dependencies except self-references)
\echo 'Migration 001: Creating User & Auth tables...'
\i ../ddl/001_users.sql
\i ../ddl/002_roles.sql
\i ../ddl/003_permissions.sql
\i ../ddl/004_user_roles.sql
\i ../ddl/005_sessions.sql
\i ../ddl/006_api_keys.sql
\i ../ddl/007_subscriptions.sql
\i ../ddl/008_billing_transactions.sql
\i ../ddl/009_audit_logs.sql
\i ../ddl/010_user_preferences.sql
\i ../ddl/011_devices.sql
\i ../ddl/012_oauth_accounts.sql
\i ../ddl/013_notifications.sql

-- MARKET DATA DOMAIN
\echo 'Migration 001: Creating Market Data tables...'
\i ../ddl/014_exchanges.sql
\i ../ddl/015_symbols.sql
\i ../ddl/016_instrument_master.sql
\i ../ddl/017_market_data_ticks.sql
\i ../ddl/018_market_data_ohlcv.sql
\i ../ddl/019_order_books.sql
\i ../ddl/020_corporate_actions.sql
\i ../ddl/021_dividends.sql
\i ../ddl/022_splits.sql
\i ../ddl/023_earnings.sql
\i ../ddl/024_economic_events.sql
\i ../ddl/025_news_articles.sql
\i ../ddl/026_sentiment_data.sql

-- COMPANY FUNDAMENTALS DOMAIN
\echo 'Migration 001: Creating Fundamentals tables...'
\i ../ddl/027_companies.sql
\i ../ddl/028_balance_sheets.sql
\i ../ddl/029_income_statements.sql
\i ../ddl/030_cash_flows.sql
\i ../ddl/031_financial_ratios.sql
\i ../ddl/032_shareholding_patterns.sql
\i ../ddl/033_mutual_fund_holdings.sql
\i ../ddl/034_institutional_holdings.sql
\i ../ddl/035_analyst_ratings.sql

-- SCREENING DOMAIN
\echo 'Migration 001: Creating Screener tables...'
\i ../ddl/036_screener_templates.sql
\i ../ddl/037_screener_filters.sql
\i ../ddl/038_saved_screeners.sql
\i ../ddl/039_screener_results_cache.sql
\i ../ddl/040_screener_executions.sql
\i ../ddl/041_custom_formulas.sql

-- PORTFOLIO DOMAIN
\echo 'Migration 001: Creating Portfolio tables...'
\i ../ddl/042_portfolios.sql
\i ../ddl/043_portfolio_positions.sql
\i ../ddl/044_portfolio_transactions.sql
\i ../ddl/045_portfolio_snapshots.sql
\i ../ddl/046_portfolio_performance.sql
\i ../ddl/047_watchlists.sql
\i ../ddl/048_watchlist_items.sql
\i ../ddl/049_goals.sql
\i ../ddl/050_rebalancing_rules.sql

-- TRADING DOMAIN
\echo 'Migration 001: Creating Trading tables...'
\i ../ddl/051_brokers.sql
\i ../ddl/052_broker_accounts.sql
\i ../ddl/053_orders.sql
\i ../ddl/054_order_fills.sql
\i ../ddl/055_executions.sql
\i ../ddl/056_positions.sql
\i ../ddl/057_risk_limits.sql
\i ../ddl/058_pnl_snapshots.sql

-- STRATEGY & BACKTEST DOMAIN
\echo 'Migration 001: Creating Strategy tables...'
\i ../ddl/059_strategies.sql
\i ../ddl/060_strategy_versions.sql
\i ../ddl/061_backtests.sql
\i ../ddl/062_backtest_results.sql
\i ../ddl/063_optimization_runs.sql
\i ../ddl/064_alpha_signals.sql

-- AI/ML DOMAIN
\echo 'Migration 001: Creating AI/ML tables...'
\i ../ddl/065_ml_models.sql
\i ../ddl/066_model_versions.sql
\i ../ddl/067_feature_store.sql
\i ../ddl/068_feature_values.sql
\i ../ddl/069_training_runs.sql
\i ../ddl/070_inference_logs.sql
\i ../ddl/071_ai_recommendations.sql
\i ../ddl/072_drift_detection.sql

-- ALERTS & EVENTS DOMAIN
\echo 'Migration 001: Creating Alerts & Events tables...'
\i ../ddl/073_alerts.sql
\i ../ddl/074_alert_events.sql
\i ../ddl/075_event_store.sql
\i ../ddl/076_websocket_sessions.sql

-- ANALYTICS DOMAIN
\echo 'Migration 001: Creating Analytics tables...'
\i ../ddl/077_kpi_metrics.sql
\i ../ddl/078_user_activity.sql
\i ../ddl/079_search_logs.sql

-- Functions
\echo 'Migration 001: Creating functions...'
\i ../functions/audit_trigger_function.sql
\i ../functions/soft_delete_function.sql
\i ../functions/portfolio_value_function.sql
\i ../functions/screener_execute_function.sql

-- Triggers
\echo 'Migration 001: Creating triggers...'
\i ../triggers/users_trigger.sql
\i ../triggers/orders_trigger.sql
\i ../triggers/portfolio_trigger.sql
\i ../triggers/alert_trigger.sql

-- Indexes
\echo 'Migration 001: Creating indexes...'
\i ../indexes/idx_users.sql
\i ../indexes/idx_sessions.sql
\i ../indexes/idx_api_keys.sql
\i ../indexes/idx_audit_logs.sql
\i ../indexes/idx_symbols.sql
\i ../indexes/idx_market_data.sql
\i ../indexes/idx_fundamentals.sql
\i ../indexes/idx_portfolio.sql
\i ../indexes/idx_trading.sql
\i ../indexes/idx_screener.sql
\i ../indexes/idx_strategies.sql
\i ../indexes/idx_ml.sql
\i ../indexes/idx_alerts_events.sql

-- Views
\echo 'Migration 001: Creating views...'
\i ../views/v_stock_overview.sql
\i ../views/v_portfolio_holdings.sql
\i ../views/v_active_alerts.sql

\echo 'Migration 001: COMPLETE'
