-- ============================================================
-- Table: sentiment_data
-- Domain: Market Data (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.sentiment_data (
    id                  UUID                NOT NULL DEFAULT gen_random_uuid(),
    symbol_id           UUID                NOT NULL,
    source              sentiment_source    NOT NULL,
    sentiment_score     NUMERIC(5,4)        NOT NULL CHECK (sentiment_score >= -1 AND sentiment_score <= 1),
    sentiment_label     sentiment_label     NOT NULL,
    volume              INTEGER             CHECK (volume IS NULL OR volume >= 0),
    timestamp           TIMESTAMPTZ         NOT NULL,
    metadata            JSONB               NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT sentiment_data_pkey PRIMARY KEY (id, timestamp),
    CONSTRAINT sentiment_data_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE sentiment_data IS 'Aggregated sentiment signals from various sources; TimescaleDB hypertable on timestamp';
COMMENT ON COLUMN sentiment_data.source IS 'Origin of sentiment: news, twitter, reddit, analyst reports, options flow, insider';
COMMENT ON COLUMN sentiment_data.volume IS 'Number of data points (tweets, articles) aggregated into this score';
