-- ============================================================
-- Table: income_statements
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS income_statements (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    company_id              UUID        NOT NULL,
    period_type             period_type NOT NULL,
    period_end_date         DATE        NOT NULL,
    report_date             DATE,
    revenue                 NUMERIC(20,2),
    cost_of_revenue         NUMERIC(20,2),
    gross_profit            NUMERIC(20,2),
    operating_expenses      NUMERIC(20,2),
    ebitda                  NUMERIC(20,2),
    ebit                    NUMERIC(20,2),
    interest_expense        NUMERIC(20,2),
    pretax_income           NUMERIC(20,2),
    income_tax              NUMERIC(20,2),
    net_income              NUMERIC(20,2),
    eps_basic               NUMERIC(12,4),
    eps_diluted             NUMERIC(12,4),
    weighted_avg_shares     BIGINT,
    dividends_paid          NUMERIC(20,2),
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT income_statements_pkey PRIMARY KEY (id),
    CONSTRAINT income_statements_company_fk FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
    CONSTRAINT income_statements_company_period_unique UNIQUE (company_id, period_type, period_end_date)
);

COMMENT ON TABLE income_statements IS 'Profit and loss statements for listed companies';
COMMENT ON COLUMN income_statements.ebitda IS 'Earnings Before Interest, Tax, Depreciation and Amortisation';
COMMENT ON COLUMN income_statements.ebit IS 'Earnings Before Interest and Tax (Operating Income)';
COMMENT ON COLUMN income_statements.eps_diluted IS 'Diluted earnings per share accounting for warrants and options';
