-- ============================================================
-- Table: watchlist_items
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.watchlist_items (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    watchlist_id    UUID            NOT NULL,
    symbol_id       UUID            NOT NULL,
    added_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    notes           TEXT,
    target_price    NUMERIC(18,6)   CHECK (target_price IS NULL OR target_price > 0),
    stop_loss       NUMERIC(18,6)   CHECK (stop_loss IS NULL OR stop_loss > 0),
    sort_order      INTEGER         NOT NULL DEFAULT 0,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT watchlist_items_pkey PRIMARY KEY (id),
    CONSTRAINT watchlist_items_watchlist_fk FOREIGN KEY (watchlist_id) REFERENCES screenerx.watchlists (id) ON DELETE CASCADE,
    CONSTRAINT watchlist_items_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT watchlist_items_watchlist_symbol_unique UNIQUE (watchlist_id, symbol_id),
    CONSTRAINT watchlist_items_target_above_stop CHECK (
        target_price IS NULL OR stop_loss IS NULL OR target_price > stop_loss
    )
);

COMMENT ON TABLE watchlist_items IS 'Individual symbol entries within a watchlist with optional targets';
COMMENT ON COLUMN watchlist_items.target_price IS 'User-set price target for this instrument';
COMMENT ON COLUMN watchlist_items.stop_loss IS 'User-set stop-loss level for this instrument';
COMMENT ON COLUMN watchlist_items.sort_order IS 'User-defined display order within the watchlist';
