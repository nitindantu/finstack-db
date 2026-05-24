-- ============================================================
-- Table: gtt_orders
-- Domain: Trading / GTT (Good-Till-Triggered)
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================
-- Mirrors GTT orders created on Zerodha Kite Connect.
-- kite_gtt_id is the integer ID returned by the Kite API.
-- trigger_values and orders are stored as JSONB to match the
-- flexible structure of Kite's GTT API response.
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.gtt_orders (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL,
    broker_account_id   UUID            NOT NULL,
    symbol_id           UUID            NOT NULL,
    trigger_type        VARCHAR(10)     NOT NULL DEFAULT 'single',
    -- single | oco (one-cancels-other)
    trigger_values      JSONB           NOT NULL DEFAULT '[]',
    -- e.g. [1800.00] for single, [1700.00, 1900.00] for OCO
    orders              JSONB           NOT NULL DEFAULT '[]',
    -- array of order specs as per Kite GTT API
    kite_gtt_id         BIGINT,
    status              VARCHAR(20)     NOT NULL DEFAULT 'active',
    -- active | triggered | cancelled | expired | disabled
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT gtt_orders_pkey PRIMARY KEY (id),
    CONSTRAINT gtt_orders_user_fk FOREIGN KEY (user_id)
        REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT gtt_orders_account_fk FOREIGN KEY (broker_account_id)
        REFERENCES quantnova.broker_accounts (id) ON DELETE RESTRICT,
    CONSTRAINT gtt_orders_symbol_fk FOREIGN KEY (symbol_id)
        REFERENCES screenerx.symbols (id) ON DELETE RESTRICT,
    CONSTRAINT gtt_orders_trigger_type_check CHECK (
        trigger_type IN ('single','oco')
    ),
    CONSTRAINT gtt_orders_status_check CHECK (
        status IN ('active','triggered','cancelled','expired','disabled')
    )
);

CREATE INDEX IF NOT EXISTS idx_gtt_orders_user
    ON screenerx.gtt_orders (user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_gtt_orders_account
    ON screenerx.gtt_orders (broker_account_id);

CREATE INDEX IF NOT EXISTS idx_gtt_orders_kite_id
    ON screenerx.gtt_orders (kite_gtt_id) WHERE kite_gtt_id IS NOT NULL;
