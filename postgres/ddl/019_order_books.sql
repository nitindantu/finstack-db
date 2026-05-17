-- ============================================================
-- Table: order_books
-- Domain: Market Data (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS order_books (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    side            order_book_side NOT NULL,
    price           NUMERIC(18,6)   NOT NULL CHECK (price > 0),
    quantity        BIGINT          NOT NULL CHECK (quantity > 0),
    order_count     INTEGER         CHECK (order_count IS NULL OR order_count > 0),
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT order_books_pkey PRIMARY KEY (symbol_id, timestamp, side, price),
    CONSTRAINT order_books_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE order_books IS 'Level-2 order book snapshots; TimescaleDB hypertable partitioned on timestamp';
COMMENT ON COLUMN order_books.side IS 'bid (buy) or ask (sell) side of the book';
COMMENT ON COLUMN order_books.price IS 'Price level in the order book';
COMMENT ON COLUMN order_books.quantity IS 'Total quantity available at this price level';
COMMENT ON COLUMN order_books.order_count IS 'Number of individual orders aggregated at this price level';
