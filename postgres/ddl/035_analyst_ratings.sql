-- ============================================================
-- Table: analyst_ratings
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS analyst_ratings (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    company_id          UUID            NOT NULL,
    analyst_firm        VARCHAR(255)    NOT NULL,
    analyst_name        VARCHAR(255),
    rating              analyst_rating  NOT NULL,
    target_price        NUMERIC(12,4)   CHECK (target_price IS NULL OR target_price > 0),
    current_price       NUMERIC(12,4)   CHECK (current_price IS NULL OR current_price > 0),
    upside_pct          NUMERIC(8,4),
    report_date         DATE            NOT NULL,
    report_url          TEXT,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT analyst_ratings_pkey PRIMARY KEY (id),
    CONSTRAINT analyst_ratings_company_fk FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE
);

COMMENT ON TABLE analyst_ratings IS 'Sell-side analyst stock ratings and price targets';
COMMENT ON COLUMN analyst_ratings.upside_pct IS 'Calculated as ((target_price / current_price) - 1) * 100';
