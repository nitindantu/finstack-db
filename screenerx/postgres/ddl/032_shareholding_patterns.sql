-- ============================================================
-- Table: shareholding_patterns
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.shareholding_patterns (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    company_id              UUID        NOT NULL,
    period_end_date         DATE        NOT NULL,
    promoter_pct            NUMERIC(6,3) NOT NULL CHECK (promoter_pct >= 0 AND promoter_pct <= 100),
    fii_pct                 NUMERIC(6,3) NOT NULL DEFAULT 0 CHECK (fii_pct >= 0 AND fii_pct <= 100),
    dii_pct                 NUMERIC(6,3) NOT NULL DEFAULT 0 CHECK (dii_pct >= 0 AND dii_pct <= 100),
    public_pct              NUMERIC(6,3) NOT NULL CHECK (public_pct >= 0 AND public_pct <= 100),
    total_shares            BIGINT      NOT NULL CHECK (total_shares > 0),
    promoter_pledged_pct    NUMERIC(6,3) CHECK (promoter_pledged_pct IS NULL OR (promoter_pledged_pct >= 0 AND promoter_pledged_pct <= 100)),
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT shareholding_patterns_pkey PRIMARY KEY (id),
    CONSTRAINT shareholding_patterns_company_fk FOREIGN KEY (company_id) REFERENCES screenerx.companies (id) ON DELETE CASCADE,
    CONSTRAINT shareholding_patterns_company_period_unique UNIQUE (company_id, period_end_date),
    CONSTRAINT shareholding_patterns_total_100 CHECK (
        ABS((promoter_pct + fii_pct + dii_pct + public_pct) - 100.0) <= 1.0
    )
);

COMMENT ON TABLE shareholding_patterns IS 'Quarterly shareholding pattern as disclosed by companies to exchanges';
COMMENT ON COLUMN shareholding_patterns.promoter_pledged_pct IS 'Percentage of promoter holding that is pledged as collateral';
COMMENT ON COLUMN shareholding_patterns.fii_pct IS 'Foreign Institutional Investors holding percentage';
COMMENT ON COLUMN shareholding_patterns.dii_pct IS 'Domestic Institutional Investors holding percentage';
