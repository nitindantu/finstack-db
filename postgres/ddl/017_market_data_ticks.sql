-- ============================================================
-- Table: market_data_ticks
-- Domain: Market Data (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS market_data_ticks (
    symbol_id       UUID            NOT NULL,
    timestamp       TIMESTAMPTZ     NOT NULL,
    price           NUMERIC(18,6)   NOT NULL CHECK (price > 0),
    volume          BIGINT          NOT NULL DEFAULT 0 CHECK (volume >= 0),
    bid             NUMERIC(18,6)   CHECK (bid IS NULL OR bid > 0),
    ask             NUMERIC(18,6)   CHECK (ask IS NULL OR ask > 0),
    bid_size        BIGINT          CHECK (bid_size IS NULL OR bid_size >= 0),
    ask_size        BIGINT          CHECK (ask_size IS NULL OR ask_size >= 0),
    trade_condition TEXT[],
    metadata        JSONB           NOT NULL DEFAULT '{}',

    CONSTRAINT market_data_ticks_pkey PRIMARY KEY (symbol_id, timestamp),
    CONSTRAINT market_data_ticks_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    CONSTRAINT market_data_ticks_spread_check CHECK (ask IS NULL OR bid IS NULL OR ask >= bid)
);

COMMENT ON TABLE market_data_ticks IS 'Raw tick-by-tick trade and quote data; TimescaleDB hypertable partitioned on timestamp';
COMMENT ON COLUMN market_data_ticks.symbol_id IS 'Instrument this tick belongs to';
COMMENT ON COLUMN market_data_ticks.timestamp IS 'Exchange timestamp of the trade or quote update';
COMMENT ON COLUMN market_data_ticks.price IS 'Last traded price';
COMMENT ON COLUMN market_data_ticks.volume IS 'Volume traded in this tick';
COMMENT ON COLUMN market_data_ticks.bid IS 'Best bid price at tick time';
COMMENT ON COLUMN market_data_ticks.ask IS 'Best ask price at tick time';
COMMENT ON COLUMN market_data_ticks.trade_condition IS 'Array of exchange trade condition codes';
