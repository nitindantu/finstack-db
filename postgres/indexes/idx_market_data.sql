-- ============================================================
-- Indexes: market_data_ticks, ohlcv tables, order_books
-- ============================================================

-- market_data_ticks
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_ticks_symbol_ts
    ON market_data_ticks (symbol_id, timestamp DESC);

-- market_data_1m
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md1m_symbol_ts
    ON market_data_1m (symbol_id, timestamp DESC);

-- market_data_5m
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md5m_symbol_ts
    ON market_data_5m (symbol_id, timestamp DESC);

-- market_data_15m
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md15m_symbol_ts
    ON market_data_15m (symbol_id, timestamp DESC);

-- market_data_1h
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md1h_symbol_ts
    ON market_data_1h (symbol_id, timestamp DESC);

-- market_data_1d
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md1d_symbol_date
    ON market_data_1d (symbol_id, date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_md1d_date
    ON market_data_1d (date DESC);

-- order_books
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_books_symbol_ts
    ON order_books (symbol_id, timestamp DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_books_symbol_side_ts
    ON order_books (symbol_id, side, timestamp DESC);
