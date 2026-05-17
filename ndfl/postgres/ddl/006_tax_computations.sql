-- ============================================================
-- Table: tax_computations
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.tax_regime_enum AS ENUM (
    'old',
    'new'
);

CREATE TABLE IF NOT EXISTS ndfl.tax_computations (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tax_year_id                 UUID NOT NULL,
    user_id                     UUID NOT NULL,
    gross_total_income          NUMERIC(18, 2) NOT NULL DEFAULT 0,
    deductions_80c              NUMERIC(18, 2) NOT NULL DEFAULT 0,   -- PPF, ELSS, LIC, PF, etc.
    deductions_80d              NUMERIC(18, 2) NOT NULL DEFAULT 0,   -- Health insurance
    deductions_80e              NUMERIC(18, 2) NOT NULL DEFAULT 0,   -- Education loan interest
    deductions_80g              NUMERIC(18, 2) NOT NULL DEFAULT 0,   -- Donations
    deductions_other            JSONB DEFAULT '{}',                  -- Other deductions by section
    total_deductions            NUMERIC(18, 2) NOT NULL DEFAULT 0,
    net_taxable_income          NUMERIC(18, 2) NOT NULL DEFAULT 0,
    tax_on_income               NUMERIC(18, 2) NOT NULL DEFAULT 0,
    surcharge                   NUMERIC(18, 2) NOT NULL DEFAULT 0,
    health_education_cess       NUMERIC(18, 2) NOT NULL DEFAULT 0,   -- 4% of (tax + surcharge)
    total_tax_liability         NUMERIC(18, 2) NOT NULL DEFAULT 0,
    advance_tax_paid            NUMERIC(18, 2) NOT NULL DEFAULT 0,
    tds_credit                  NUMERIC(18, 2) NOT NULL DEFAULT 0,
    self_assessment_tax         NUMERIC(18, 2) NOT NULL DEFAULT 0,
    tax_payable_or_refund       NUMERIC(18, 2) NOT NULL DEFAULT 0,  -- positive = payable, negative = refund
    regime_type                 ndfl.tax_regime_enum NOT NULL DEFAULT 'new',
    computation_details         JSONB DEFAULT '{}',                  -- slab-wise breakup
    metadata                    JSONB DEFAULT '{}',
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ,

    CONSTRAINT tax_computations_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE,
    CONSTRAINT tax_computations_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT tax_computations_tax_year_uq UNIQUE (tax_year_id, regime_type)
);

COMMENT ON TABLE ndfl.tax_computations IS 'Detailed tax computation per tax year and regime';
COMMENT ON COLUMN ndfl.tax_computations.deductions_other IS 'JSON map of section code to deduction amount, e.g. {"80TTA": 10000, "80CCD": 50000}';
