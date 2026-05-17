-- ============================================================
-- Table: tax_years
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE SCHEMA IF NOT EXISTS ndfl;

CREATE TYPE IF NOT EXISTS ndfl.filing_status_enum AS ENUM (
    'not_started',
    'in_progress',
    'filed',
    'revised',
    'defective'
);

CREATE TYPE IF NOT EXISTS ndfl.itr_form_type_enum AS ENUM (
    'ITR1',
    'ITR2',
    'ITR3',
    'ITR4'
);

CREATE TABLE IF NOT EXISTS ndfl.tax_years (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL,
    assessment_year         VARCHAR(10) NOT NULL,           -- e.g. '2024-25'
    financial_year_start    DATE NOT NULL,
    financial_year_end      DATE NOT NULL,
    filing_status           ndfl.filing_status_enum NOT NULL DEFAULT 'not_started',
    filing_deadline         DATE,
    filed_at                TIMESTAMPTZ,
    acknowledgement_number  VARCHAR(50),
    itr_form_type           ndfl.itr_form_type_enum,
    total_income            NUMERIC(18, 2),
    taxable_income          NUMERIC(18, 2),
    total_tax               NUMERIC(18, 2),
    tax_paid                NUMERIC(18, 2),
    tax_refund              NUMERIC(18, 2),
    tax_payable             NUMERIC(18, 2),
    metadata                JSONB DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,

    CONSTRAINT tax_years_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT tax_years_assessment_year_user_uq UNIQUE (user_id, assessment_year)
);

COMMENT ON TABLE ndfl.tax_years IS 'Income tax filing records per user per assessment year';
COMMENT ON COLUMN ndfl.tax_years.assessment_year IS 'Assessment year in format YYYY-YY, e.g. 2024-25';
