-- ============================================================
-- Indexes: symbols
-- ============================================================

-- Ticker lookup (search hot path)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_ticker
    ON symbols (ticker)
    WHERE is_active = TRUE;

-- Exchange filter
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_exchange_id
    ON symbols (exchange_id)
    WHERE is_active = TRUE;

-- ISIN lookup
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_isin
    ON symbols (isin)
    WHERE isin IS NOT NULL AND is_active = TRUE;

-- Sector + industry for screener
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_sector
    ON symbols (sector)
    WHERE is_active = TRUE;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_sector_industry
    ON symbols (sector, industry)
    WHERE is_active = TRUE;

-- Instrument type
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_instrument_type
    ON symbols (instrument_type)
    WHERE is_active = TRUE;

-- Market cap category
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_market_cap_category
    ON symbols (market_cap_category)
    WHERE is_active = TRUE;

-- Full-text search on name
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_name_trgm
    ON symbols USING gin (name gin_trgm_ops);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_ticker_trgm
    ON symbols USING gin (ticker gin_trgm_ops);

-- JSONB metadata
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_symbols_metadata
    ON symbols USING gin (metadata);
