-- ============================================================
-- Migration: 001_create_schema
-- Domain: quantnova (quantitative trading platform)
-- Requires: shared and screenerx schemas to be created first
-- ============================================================

CREATE SCHEMA IF NOT EXISTS quantnova;

-- Brokers & Execution
\i quantnova/postgres/ddl/051_brokers.sql
\i quantnova/postgres/ddl/052_broker_accounts.sql
\i quantnova/postgres/ddl/053_orders.sql
\i quantnova/postgres/ddl/054_order_fills.sql
\i quantnova/postgres/ddl/055_executions.sql
\i quantnova/postgres/ddl/056_positions.sql
\i quantnova/postgres/ddl/057_risk_limits.sql
\i quantnova/postgres/ddl/058_pnl_snapshots.sql

-- Strategies & Backtesting
\i quantnova/postgres/ddl/059_strategies.sql
\i quantnova/postgres/ddl/060_strategy_versions.sql
\i quantnova/postgres/ddl/061_backtests.sql
\i quantnova/postgres/ddl/062_backtest_results.sql
\i quantnova/postgres/ddl/063_optimization_runs.sql
\i quantnova/postgres/ddl/064_alpha_signals.sql

-- ML & AI
\i quantnova/postgres/ddl/065_ml_models.sql
\i quantnova/postgres/ddl/066_model_versions.sql
\i quantnova/postgres/ddl/067_feature_store.sql
\i quantnova/postgres/ddl/068_feature_values.sql
\i quantnova/postgres/ddl/069_training_runs.sql
\i quantnova/postgres/ddl/070_inference_logs.sql
\i quantnova/postgres/ddl/071_ai_recommendations.sql
\i quantnova/postgres/ddl/072_drift_detection.sql

-- Event sourcing
\i quantnova/postgres/ddl/075_event_store.sql

-- Indexes
\i quantnova/postgres/indexes/idx_trading.sql
\i quantnova/postgres/indexes/idx_strategies.sql
\i quantnova/postgres/indexes/idx_ml.sql

-- Triggers
\i quantnova/postgres/triggers/orders_trigger.sql

-- Seed data
\i quantnova/postgres/dml/seed_008_trading.sql
