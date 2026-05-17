-- ============================================================
-- Table: executions
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS executions (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    order_id            UUID            NOT NULL,
    execution_price     NUMERIC(18,6)   NOT NULL CHECK (execution_price > 0),
    execution_quantity  NUMERIC(18,6)   NOT NULL CHECK (execution_quantity > 0),
    execution_time      TIMESTAMPTZ     NOT NULL,
    charges             JSONB           NOT NULL DEFAULT '{}',
    taxes               JSONB           NOT NULL DEFAULT '{}',
    net_amount          NUMERIC(20,2)   NOT NULL,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT executions_pkey PRIMARY KEY (id),
    CONSTRAINT executions_order_fk FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
);

COMMENT ON TABLE executions IS 'Confirmed trade executions with full charges and tax breakdown';
COMMENT ON COLUMN executions.charges IS 'JSON breakdown: {brokerage, exchange_fee, sebi_fee, dp_charges, ...}';
COMMENT ON COLUMN executions.taxes IS 'JSON breakdown: {stt, gst, stamp_duty, ...}';
COMMENT ON COLUMN executions.net_amount IS 'Final settlement amount after all charges and taxes';
