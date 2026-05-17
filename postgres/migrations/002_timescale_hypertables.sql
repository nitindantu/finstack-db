-- ============================================================
-- Migration 002: TimescaleDB Hypertables & Policies
-- Run AFTER migration 001
-- Requires TimescaleDB extension to be installed and loaded
-- ============================================================

\echo 'Migration 002: Creating hypertables...'
\i ../../timescaledb/hypertables/create_hypertables.sql

\echo 'Migration 002: Creating compression policies...'
\i ../../timescaledb/compression/compression_policies.sql

\echo 'Migration 002: Creating retention policies...'
\i ../../timescaledb/retention/retention_policies.sql

\echo 'Migration 002: Creating continuous aggregates...'
\i ../../timescaledb/continuous_aggregates/cagg_market_data_5m.sql
\i ../../timescaledb/continuous_aggregates/cagg_market_data_1h.sql
\i ../../timescaledb/continuous_aggregates/cagg_daily_volume_profile.sql

\echo 'Migration 002: COMPLETE'
