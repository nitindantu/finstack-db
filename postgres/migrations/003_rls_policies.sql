-- ============================================================
-- Migration 003: Row Level Security Policies
-- Run AFTER migration 001 (tables must exist)
-- ============================================================

\echo 'Migration 003: Applying RLS policies...'
\i ../rls/rls_policies.sql

\echo 'Migration 003: Creating materialized views...'
\i ../materialized_views/mv_stock_daily_summary.sql
\i ../materialized_views/mv_sector_performance.sql
\i ../materialized_views/mv_top_movers.sql
\i ../materialized_views/mv_portfolio_summary.sql

\echo 'Migration 003: COMPLETE'
