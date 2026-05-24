-- ============================================================
-- Migration: 002_trading_engine_alterations
-- Schema: quantnova
-- Version: v1.4.0 — Native Trade Execution Engine
-- Applied: 2026-05-24
-- ============================================================
-- Additive ALTER TABLE statements for existing quantnova tables.
-- All statements use IF NOT EXISTS — safe to re-run.
-- ============================================================

-- orders: Kite Connect execution + iceberg fields
ALTER TABLE quantnova.orders
    ADD COLUMN IF NOT EXISTS average_price  NUMERIC(18,6),
    ADD COLUMN IF NOT EXISTS filled_qty     NUMERIC(18,6) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS exchange_time  TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS kite_order_id  VARCHAR(100),
    ADD COLUMN IF NOT EXISTS tag            VARCHAR(100),
    ADD COLUMN IF NOT EXISTS iceberg_legs   INTEGER,
    ADD COLUMN IF NOT EXISTS iceberg_qty    NUMERIC(18,6);

CREATE INDEX IF NOT EXISTS idx_orders_kite_order_id
    ON quantnova.orders (kite_order_id)
    WHERE kite_order_id IS NOT NULL;

-- positions: M2M and realised/unrealised PnL breakdown
ALTER TABLE quantnova.positions
    ADD COLUMN IF NOT EXISTS m2m            NUMERIC(20,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS realised_pnl   NUMERIC(20,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS unrealised_pnl NUMERIC(20,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS multiplier     INTEGER       NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS close_price    NUMERIC(18,6);

-- broker_accounts: broker identity and sync tracking
ALTER TABLE quantnova.broker_accounts
    ADD COLUMN IF NOT EXISTS broker_type    VARCHAR(50) NOT NULL DEFAULT 'zerodha',
    ADD COLUMN IF NOT EXISTS client_id      VARCHAR(50),
    ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ;
