-- ============================================================
-- Table: institutional_holdings
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS institutional_holdings (
    id                  UUID                NOT NULL DEFAULT gen_random_uuid(),
    company_id          UUID                NOT NULL,
    institution_name    VARCHAR(500)        NOT NULL,
    institution_type    institution_type    NOT NULL,
    period_end_date     DATE                NOT NULL,
    shares_held         BIGINT              NOT NULL CHECK (shares_held >= 0),
    value               NUMERIC(20,2)       CHECK (value IS NULL OR value >= 0),
    change_in_shares    BIGINT,
    metadata            JSONB               NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT institutional_holdings_pkey PRIMARY KEY (id),
    CONSTRAINT institutional_holdings_company_fk FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
    CONSTRAINT institutional_holdings_unique UNIQUE (company_id, institution_name, period_end_date)
);

COMMENT ON TABLE institutional_holdings IS 'Institutional investor holding disclosures per company per period';
COMMENT ON COLUMN institutional_holdings.change_in_shares IS 'Positive = bought, negative = sold vs previous period';
