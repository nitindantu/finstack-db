-- ============================================================
-- Table: financial_ratios
-- Domain: Company Fundamentals (TimescaleDB hypertable on as_of_date)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.financial_ratios (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    company_id              UUID            NOT NULL,
    symbol_id               UUID            NOT NULL,
    as_of_date              DATE            NOT NULL,
    pe_ratio                NUMERIC(12,4),
    pb_ratio                NUMERIC(12,4),
    ps_ratio                NUMERIC(12,4),
    ev_ebitda               NUMERIC(12,4),
    roe                     NUMERIC(10,4),
    roa                     NUMERIC(10,4),
    roce                    NUMERIC(10,4),
    roic                    NUMERIC(10,4),
    debt_to_equity          NUMERIC(12,4),
    current_ratio           NUMERIC(10,4),
    quick_ratio             NUMERIC(10,4),
    interest_coverage       NUMERIC(12,4),
    dividend_yield          NUMERIC(10,6),
    payout_ratio            NUMERIC(10,4),
    earnings_yield          NUMERIC(10,6),
    fcf_yield               NUMERIC(10,6),
    revenue_growth_yoy      NUMERIC(10,4),
    earnings_growth_yoy     NUMERIC(10,4),
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT financial_ratios_pkey PRIMARY KEY (id, as_of_date),
    CONSTRAINT financial_ratios_company_fk FOREIGN KEY (company_id) REFERENCES screenerx.companies (id) ON DELETE CASCADE,
    CONSTRAINT financial_ratios_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT financial_ratios_company_date_unique UNIQUE (company_id, as_of_date),
    CONSTRAINT financial_ratios_yield_range CHECK (dividend_yield IS NULL OR (dividend_yield >= 0 AND dividend_yield <= 1)),
    CONSTRAINT financial_ratios_payout_range CHECK (payout_ratio IS NULL OR payout_ratio >= 0)
);

COMMENT ON TABLE financial_ratios IS 'Daily snapshot of valuation and performance ratios; TimescaleDB hypertable';
COMMENT ON COLUMN financial_ratios.pe_ratio IS 'Price-to-Earnings ratio (market price / EPS TTM)';
COMMENT ON COLUMN financial_ratios.ev_ebitda IS 'Enterprise Value to EBITDA multiple';
COMMENT ON COLUMN financial_ratios.roic IS 'Return on Invested Capital';
COMMENT ON COLUMN financial_ratios.fcf_yield IS 'Free Cash Flow yield (FCF / Market Cap)';
