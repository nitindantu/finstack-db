-- ============================================================
-- Tables: market_data_1m, 5m, 15m, 1h, 1d
-- Domain: Market Data (TimescaleDB hypertables)
-- ============================================================

-- 1-minute OHLCV bars
CREATE TABLE IF NOT EXISTS market_data_1m (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    open            NUMERIC(18,6)   NOT NULL CHECK (open > 0),
    high            NUMERIC(18,6)   NOT NULL CHECK (high > 0),
    low             NUMERIC(18,6)   NOT NULL CHECK (low > 0),
    close           NUMERIC(18,6)   NOT NULL CHECK (close > 0),
    volume          BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    vwap            NUMERIC(18,6)   CHECK (vwap IS NULL OR vwap > 0),
    trades_count    INTEGER         CHECK (trades_count IS NULL OR trades_count >= 0),
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_1m_pkey PRIMARY KEY (symbol_id, timestamp),
    CONSTRAINT market_data_1m_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_1m_hl_check CHECK (high >= low),
    CONSTRAINT market_data_1m_oc_within_hl CHECK (open BETWEEN low AND high AND close BETWEEN low AND high)
);

COMMENT ON TABLE market_data_1m IS '1-minute OHLCV candlestick data; TimescaleDB hypertable';

-- 5-minute OHLCV bars
CREATE TABLE IF NOT EXISTS market_data_5m (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    open            NUMERIC(18,6)   NOT NULL CHECK (open > 0),
    high            NUMERIC(18,6)   NOT NULL CHECK (high > 0),
    low             NUMERIC(18,6)   NOT NULL CHECK (low > 0),
    close           NUMERIC(18,6)   NOT NULL CHECK (close > 0),
    volume          BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    vwap            NUMERIC(18,6)   CHECK (vwap IS NULL OR vwap > 0),
    trades_count    INTEGER         CHECK (trades_count IS NULL OR trades_count >= 0),
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_5m_pkey PRIMARY KEY (symbol_id, timestamp),
    CONSTRAINT market_data_5m_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_5m_hl_check CHECK (high >= low),
    CONSTRAINT market_data_5m_oc_within_hl CHECK (open BETWEEN low AND high AND close BETWEEN low AND high)
);

COMMENT ON TABLE market_data_5m IS '5-minute OHLCV candlestick data; TimescaleDB hypertable';

-- 15-minute OHLCV bars
CREATE TABLE IF NOT EXISTS market_data_15m (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    open            NUMERIC(18,6)   NOT NULL CHECK (open > 0),
    high            NUMERIC(18,6)   NOT NULL CHECK (high > 0),
    low             NUMERIC(18,6)   NOT NULL CHECK (low > 0),
    close           NUMERIC(18,6)   NOT NULL CHECK (close > 0),
    volume          BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    vwap            NUMERIC(18,6)   CHECK (vwap IS NULL OR vwap > 0),
    trades_count    INTEGER         CHECK (trades_count IS NULL OR trades_count >= 0),
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_15m_pkey PRIMARY KEY (symbol_id, timestamp),
    CONSTRAINT market_data_15m_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_15m_hl_check CHECK (high >= low),
    CONSTRAINT market_data_15m_oc_within_hl CHECK (open BETWEEN low AND high AND close BETWEEN low AND high)
);

COMMENT ON TABLE market_data_15m IS '15-minute OHLCV candlestick data; TimescaleDB hypertable';

-- 1-hour OHLCV bars
CREATE TABLE IF NOT EXISTS market_data_1h (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    open            NUMERIC(18,6)   NOT NULL CHECK (open > 0),
    high            NUMERIC(18,6)   NOT NULL CHECK (high > 0),
    low             NUMERIC(18,6)   NOT NULL CHECK (low > 0),
    close           NUMERIC(18,6)   NOT NULL CHECK (close > 0),
    volume          BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    vwap            NUMERIC(18,6)   CHECK (vwap IS NULL OR vwap > 0),
    trades_count    INTEGER         CHECK (trades_count IS NULL OR trades_count >= 0),
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_1h_pkey PRIMARY KEY (symbol_id, timestamp),
    CONSTRAINT market_data_1h_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_1h_hl_check CHECK (high >= low),
    CONSTRAINT market_data_1h_oc_within_hl CHECK (open BETWEEN low AND high AND close BETWEEN low AND high)
);

COMMENT ON TABLE market_data_1h IS '1-hour OHLCV candlestick data; TimescaleDB hypertable';

-- Daily OHLCV bars (richer with delivery volume)
CREATE TABLE IF NOT EXISTS market_data_1d (
    symbol_id           UUID            NOT NULL,
    date                DATE            NOT NULL,
    open                NUMERIC(18,6)   NOT NULL CHECK (open > 0),
    high                NUMERIC(18,6)   NOT NULL CHECK (high > 0),
    low                 NUMERIC(18,6)   NOT NULL CHECK (low > 0),
    close               NUMERIC(18,6)   NOT NULL CHECK (close > 0),
    volume              BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    adj_close           NUMERIC(18,6)   CHECK (adj_close IS NULL OR adj_close > 0),
    vwap                NUMERIC(18,6)   CHECK (vwap IS NULL OR vwap > 0),
    delivery_volume     BIGINT          CHECK (delivery_volume IS NULL OR delivery_volume >= 0),
    delivery_pct        NUMERIC(6,3)    CHECK (delivery_pct IS NULL OR (delivery_pct >= 0 AND delivery_pct <= 100)),
    trades_count        INTEGER         CHECK (trades_count IS NULL OR trades_count >= 0),
    metadata            JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_1d_pkey PRIMARY KEY (symbol_id, date),
    CONSTRAINT market_data_1d_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_1d_hl_check CHECK (high >= low),
    CONSTRAINT market_data_1d_oc_within_hl CHECK (open BETWEEN low AND high AND close BETWEEN low AND high),
    CONSTRAINT market_data_1d_delivery_le_volume CHECK (delivery_volume IS NULL OR delivery_volume <= volume)
);

COMMENT ON TABLE market_data_1d IS 'Daily OHLCV data with delivery statistics; TimescaleDB hypertable';
COMMENT ON COLUMN market_data_1d.adj_close IS 'Split and dividend-adjusted closing price';
COMMENT ON COLUMN market_data_1d.delivery_volume IS 'Shares resulting in actual delivery (NSE-specific)';
COMMENT ON COLUMN market_data_1d.delivery_pct IS 'Delivery volume as percentage of total volume';
