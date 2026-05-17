-- ============================================================
-- Table: balance_sheets
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS balance_sheets (
    id                          UUID        NOT NULL DEFAULT gen_random_uuid(),
    company_id                  UUID        NOT NULL,
    period_type                 period_type NOT NULL,
    period_end_date             DATE        NOT NULL,
    report_date                 DATE,
    total_assets                NUMERIC(20,2),
    total_liabilities           NUMERIC(20,2),
    total_equity                NUMERIC(20,2),
    current_assets              NUMERIC(20,2),
    current_liabilities         NUMERIC(20,2),
    cash_equivalents            NUMERIC(20,2),
    short_term_investments      NUMERIC(20,2),
    accounts_receivable         NUMERIC(20,2),
    inventory                   NUMERIC(20,2),
    property_plant_equipment    NUMERIC(20,2),
    goodwill                    NUMERIC(20,2),
    total_debt                  NUMERIC(20,2),
    long_term_debt              NUMERIC(20,2),
    short_term_debt             NUMERIC(20,2),
    retained_earnings           NUMERIC(20,2),
    common_stock                NUMERIC(20,2),
    metadata                    JSONB       NOT NULL DEFAULT '{}',
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ,
    created_by                  UUID,
    updated_by                  UUID,

    CONSTRAINT balance_sheets_pkey PRIMARY KEY (id),
    CONSTRAINT balance_sheets_company_fk FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
    CONSTRAINT balance_sheets_company_period_unique UNIQUE (company_id, period_type, period_end_date)
);

COMMENT ON TABLE balance_sheets IS 'Periodic balance sheet statements for listed companies';
COMMENT ON COLUMN balance_sheets.period_type IS 'Q1/Q2/Q3/Q4/Annual/TTM';
COMMENT ON COLUMN balance_sheets.report_date IS 'Date when the financial results were officially filed/published';
