-- ============================================================
-- Table: order_executions
-- Domain: Trading / Kite Connect
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================
-- Individual fill events (partial or full) for each order.
-- Multiple rows per order are expected for partial fills.
-- Insert-only — no updates after a fill is recorded.
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.order_executions (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    order_id            UUID            NOT NULL,
    broker_account_id   UUID            NOT NULL,
    fill_qty            NUMERIC(18,6)   NOT NULL CHECK (fill_qty > 0),
    fill_price          NUMERIC(18,6)   NOT NULL CHECK (fill_price > 0),
    exchange_time       TIMESTAMPTZ,
    exchange_order_id   VARCHAR(100),
    trade_id            VARCHAR(100),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT order_executions_pkey PRIMARY KEY (id),
    CONSTRAINT order_executions_order_fk FOREIGN KEY (order_id)
        REFERENCES quantnova.orders (id) ON DELETE CASCADE,
    CONSTRAINT order_executions_account_fk FOREIGN KEY (broker_account_id)
        REFERENCES quantnova.broker_accounts (id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_order_executions_order
    ON screenerx.order_executions (order_id);

CREATE INDEX IF NOT EXISTS idx_order_executions_account
    ON screenerx.order_executions (broker_account_id, created_at DESC);
