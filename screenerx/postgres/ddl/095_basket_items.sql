-- ============================================================
-- Table: basket_items
-- Domain: Trading / Basket Orders
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================
-- Individual order legs within a basket.
-- sort_order controls execution sequence.
-- order_id is populated once the leg is successfully placed.
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.basket_items (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    basket_id       UUID            NOT NULL,
    symbol_id       UUID,
    -- nullable to allow symbol lookup by ticker at execution time
    side            VARCHAR(4)      NOT NULL CHECK (side IN ('buy','sell')),
    quantity        NUMERIC(18,6)   NOT NULL CHECK (quantity > 0),
    order_type      VARCHAR(20)     NOT NULL DEFAULT 'market',
    price           NUMERIC(18,6)   CHECK (price IS NULL OR price > 0),
    trigger_price   NUMERIC(18,6)   CHECK (trigger_price IS NULL OR trigger_price > 0),
    product_type    VARCHAR(20)     NOT NULL DEFAULT 'intraday',
    status          VARCHAR(20)     NOT NULL DEFAULT 'pending',
    -- pending | placed | filled | failed | skipped
    order_id        UUID,
    -- FK to quantnova.orders once placed
    error_msg       TEXT,
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT basket_items_pkey PRIMARY KEY (id),
    CONSTRAINT basket_items_basket_fk FOREIGN KEY (basket_id)
        REFERENCES screenerx.baskets (id) ON DELETE CASCADE,
    CONSTRAINT basket_items_symbol_fk FOREIGN KEY (symbol_id)
        REFERENCES screenerx.symbols (id) ON DELETE RESTRICT,
    CONSTRAINT basket_items_order_fk FOREIGN KEY (order_id)
        REFERENCES quantnova.orders (id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_basket_items_basket
    ON screenerx.basket_items (basket_id, sort_order);
