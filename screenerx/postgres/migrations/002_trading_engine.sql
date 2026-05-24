-- ============================================================
-- Migration: 002_trading_engine
-- Schema: screenerx
-- Version: v1.4.0 — Native Trade Execution Engine
-- Applied: 2026-05-24
-- ============================================================
-- Run this file against the Neon DB after 001_create_schema.sql.
-- All statements are idempotent (IF NOT EXISTS / IF NOT EXISTS).
-- ============================================================

\ir ../ddl/092_broker_sessions.sql
\ir ../ddl/093_order_executions.sql
\ir ../ddl/094_baskets.sql
\ir ../ddl/095_basket_items.sql
\ir ../ddl/096_gtt_orders.sql
\ir ../ddl/097_trading_audit_logs.sql
