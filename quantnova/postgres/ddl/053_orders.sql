-- ============================================================
-- Table: orders
-- Domain: Trading
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.orders (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID            NOT NULL,
    portfolio_id            UUID,
    broker_account_id       UUID,
    symbol_id               UUID            NOT NULL,
    order_type              order_type      NOT NULL DEFAULT 'market',
    side                    order_side      NOT NULL,
    quantity                NUMERIC(18,6)   NOT NULL CHECK (quantity > 0),
    price                   NUMERIC(18,6)   CHECK (price IS NULL OR price > 0),
    trigger_price           NUMERIC(18,6)   CHECK (trigger_price IS NULL OR trigger_price > 0),
    disclosed_qty           NUMERIC(18,6)   CHECK (disclosed_qty IS NULL OR disclosed_qty > 0),
    product_type            product_type    NOT NULL DEFAULT 'delivery',
    status                  order_status    NOT NULL DEFAULT 'pending',
    broker_order_id         VARCHAR(100),
    exchange_order_id       VARCHAR(100),
    parent_order_id         UUID,
    validity                order_validity  NOT NULL DEFAULT 'day',
    placed_at               TIMESTAMPTZ,
    executed_at             TIMESTAMPTZ,
    cancelled_at            TIMESTAMPTZ,
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT orders_pkey PRIMARY KEY (id),
    CONSTRAINT orders_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE RESTRICT,
    CONSTRAINT orders_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE SET NULL,
    CONSTRAINT orders_broker_account_fk FOREIGN KEY (broker_account_id) REFERENCES quantnova.broker_accounts (id) ON DELETE SET NULL,
    CONSTRAINT orders_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE RESTRICT,
    CONSTRAINT orders_parent_fk FOREIGN KEY (parent_order_id) REFERENCES quantnova.orders (id) ON DELETE SET NULL,
    CONSTRAINT orders_limit_requires_price CHECK (
        order_type NOT IN ('limit','stop_limit') OR price IS NOT NULL
    ),
    CONSTRAINT orders_stop_requires_trigger CHECK (
        order_type NOT IN ('stop','stop_limit') OR trigger_price IS NOT NULL
    ),
    CONSTRAINT orders_disclosed_le_quantity CHECK (
        disclosed_qty IS NULL OR disclosed_qty <= quantity
    )
);

COMMENT ON TABLE orders IS 'Order lifecycle records for all trading activity';
COMMENT ON COLUMN orders.order_type IS 'market/limit/stop/stop_limit/bracket/cover/trailing_stop';
COMMENT ON COLUMN orders.product_type IS 'Margin product classification: intraday/delivery/futures/options';
COMMENT ON COLUMN orders.disclosed_qty IS 'Iceberg order visible quantity; NULL means full quantity disclosed';
COMMENT ON COLUMN orders.parent_order_id IS 'For bracket/cover legs referencing the parent order';
