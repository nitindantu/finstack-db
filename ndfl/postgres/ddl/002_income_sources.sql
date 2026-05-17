-- ============================================================
-- Table: income_sources
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.income_source_type_enum AS ENUM (
    'salary',
    'business',
    'capital_gains',
    'house_property',
    'other_sources',
    'agriculture'
);

CREATE TABLE IF NOT EXISTS ndfl.income_sources (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tax_year_id     UUID NOT NULL,
    user_id         UUID NOT NULL,
    source_type     ndfl.income_source_type_enum NOT NULL,
    employer_name   VARCHAR(255),
    pan_of_payer    VARCHAR(10),
    gross_amount    NUMERIC(18, 2) NOT NULL DEFAULT 0,
    exempt_amount   NUMERIC(18, 2) NOT NULL DEFAULT 0,
    taxable_amount  NUMERIC(18, 2) NOT NULL DEFAULT 0,
    tds_deducted    NUMERIC(18, 2) NOT NULL DEFAULT 0,
    period_from     DATE,
    period_to       DATE,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT income_sources_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE,
    CONSTRAINT income_sources_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.income_sources IS 'Individual income sources per tax year for a user';
