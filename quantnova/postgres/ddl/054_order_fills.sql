-- ============================================================
-- Table: order_fills
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.order_fills (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    order_id            UUID            NOT NULL,
    fill_price          NUMERIC(18,6)   NOT NULL CHECK (fill_price > 0),
    fill_quantity       NUMERIC(18,6)   NOT NULL CHECK (fill_quantity > 0),
    fill_time           TIMESTAMPTZ     NOT NULL,
    exchange_trade_id   VARCHAR(100),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT order_fills_pkey PRIMARY KEY (id),
    CONSTRAINT order_fills_order_fk FOREIGN KEY (order_id) REFERENCES quantnova.orders (id) ON DELETE CASCADE
);

COMMENT ON TABLE order_fills IS 'Individual exchange-level trade executions (fills) for an order';
COMMENT ON COLUMN order_fills.exchange_trade_id IS 'Unique trade ID assigned by the exchange';
