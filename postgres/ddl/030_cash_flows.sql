-- ============================================================
-- Table: cash_flows
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS cash_flows (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    company_id              UUID        NOT NULL,
    period_type             period_type NOT NULL,
    period_end_date         DATE        NOT NULL,
    report_date             DATE,
    operating_cash_flow     NUMERIC(20,2),
    investing_cash_flow     NUMERIC(20,2),
    financing_cash_flow     NUMERIC(20,2),
    net_cash_change         NUMERIC(20,2),
    capex                   NUMERIC(20,2),
    free_cash_flow          NUMERIC(20,2),
    dividends_paid          NUMERIC(20,2),
    debt_repayment          NUMERIC(20,2),
    share_buybacks          NUMERIC(20,2),
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT cash_flows_pkey PRIMARY KEY (id),
    CONSTRAINT cash_flows_company_fk FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
    CONSTRAINT cash_flows_company_period_unique UNIQUE (company_id, period_type, period_end_date)
);

COMMENT ON TABLE cash_flows IS 'Cash flow statements for listed companies';
COMMENT ON COLUMN cash_flows.free_cash_flow IS 'operating_cash_flow - capex';
COMMENT ON COLUMN cash_flows.capex IS 'Capital expenditure (negative in the investing section)';
