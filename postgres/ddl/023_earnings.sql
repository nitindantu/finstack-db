-- ============================================================
-- Table: earnings
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS earnings (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    symbol_id               UUID        NOT NULL,
    period_type             period_type NOT NULL,
    period_end_date         DATE        NOT NULL,
    report_date             DATE,
    eps_actual              NUMERIC(12,4),
    eps_estimated           NUMERIC(12,4),
    eps_surprise            NUMERIC(12,4),
    eps_surprise_pct        NUMERIC(8,4),
    revenue_actual          NUMERIC(20,2),
    revenue_estimated       NUMERIC(20,2),
    guidance_low            NUMERIC(20,2),
    guidance_high           NUMERIC(20,2),
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT earnings_pkey PRIMARY KEY (id),
    CONSTRAINT earnings_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    CONSTRAINT earnings_symbol_period_unique UNIQUE (symbol_id, period_type, period_end_date),
    CONSTRAINT earnings_guidance_range CHECK (guidance_high IS NULL OR guidance_low IS NULL OR guidance_high >= guidance_low)
);

COMMENT ON TABLE earnings IS 'Quarterly and annual earnings reports with estimates and actuals';
COMMENT ON COLUMN earnings.eps_surprise IS 'eps_actual - eps_estimated';
COMMENT ON COLUMN earnings.eps_surprise_pct IS 'Surprise as percentage of estimate';
COMMENT ON COLUMN earnings.guidance_low IS 'Lower bound of management guidance for next period';
COMMENT ON COLUMN earnings.guidance_high IS 'Upper bound of management guidance for next period';
