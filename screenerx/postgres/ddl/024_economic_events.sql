-- ============================================================
-- Table: economic_events
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.economic_events (
    id                  UUID                NOT NULL DEFAULT gen_random_uuid(),
    event_name          VARCHAR(500)        NOT NULL,
    country             CHAR(2)             NOT NULL,
    event_date          TIMESTAMPTZ         NOT NULL,
    actual_value        NUMERIC(18,6),
    forecast_value      NUMERIC(18,6),
    previous_value      NUMERIC(18,6),
    importance          event_importance    NOT NULL DEFAULT 'medium',
    currency_impact     TEXT[],
    metadata            JSONB               NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT economic_events_pkey PRIMARY KEY (id),
    CONSTRAINT economic_events_country_format CHECK (country ~ '^[A-Z]{2}$')
);

COMMENT ON TABLE economic_events IS 'Macro-economic calendar events (GDP, CPI, interest rates, etc.)';
COMMENT ON COLUMN economic_events.currency_impact IS 'Array of ISO currency codes that this event typically impacts';
COMMENT ON COLUMN economic_events.importance IS 'Market impact classification: low/medium/high';
