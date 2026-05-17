-- ============================================================
-- Table: mutual_fund_holdings
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.mutual_fund_holdings (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    company_id          UUID            NOT NULL,
    fund_id             VARCHAR(50)     NOT NULL,
    fund_name           VARCHAR(500)    NOT NULL,
    amc_name            VARCHAR(255)    NOT NULL,
    period_end_date     DATE            NOT NULL,
    shares_held         BIGINT          NOT NULL CHECK (shares_held > 0),
    value               NUMERIC(20,2)   NOT NULL CHECK (value > 0),
    pct_of_portfolio    NUMERIC(8,4)    CHECK (pct_of_portfolio IS NULL OR (pct_of_portfolio >= 0 AND pct_of_portfolio <= 100)),
    pct_of_company      NUMERIC(8,4)    CHECK (pct_of_company IS NULL OR (pct_of_company >= 0 AND pct_of_company <= 100)),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT mutual_fund_holdings_pkey PRIMARY KEY (id),
    CONSTRAINT mutual_fund_holdings_company_fk FOREIGN KEY (company_id) REFERENCES screenerx.companies (id) ON DELETE CASCADE,
    CONSTRAINT mutual_fund_holdings_unique UNIQUE (company_id, fund_id, period_end_date)
);

COMMENT ON TABLE mutual_fund_holdings IS 'Monthly mutual fund scheme-level holdings in a company';
COMMENT ON COLUMN mutual_fund_holdings.fund_id IS 'AMFI scheme code or internal fund identifier';
COMMENT ON COLUMN mutual_fund_holdings.pct_of_portfolio IS 'This stock as a percentage of the fund''s total AUM';
COMMENT ON COLUMN mutual_fund_holdings.pct_of_company IS 'Fund''s holding as a percentage of total company equity';
