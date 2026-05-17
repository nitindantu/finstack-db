-- ============================================================
-- Table: tax_payments
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.tax_payment_type_enum AS ENUM (
    'advance_tax',
    'self_assessment',
    'regular_assessment'
);

CREATE TABLE IF NOT EXISTS ndfl.tax_payments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,
    payment_type        ndfl.tax_payment_type_enum NOT NULL,
    payment_date        DATE NOT NULL,
    amount              NUMERIC(18, 2) NOT NULL,
    challan_number      VARCHAR(50),
    bsr_code            VARCHAR(10),                 -- Basic Statistical Return code of bank branch
    bank_name           VARCHAR(255),
    assessment_year     VARCHAR(10),                 -- e.g. '2024-25'
    minor_head_code     VARCHAR(10),                 -- 100=Advance Tax, 300=Self Assessment
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,

    CONSTRAINT tax_payments_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT tax_payments_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.tax_payments IS 'Tax payments made via challan (advance tax, self-assessment, regular assessment)';
COMMENT ON COLUMN ndfl.tax_payments.bsr_code IS 'Basic Statistical Return code identifying the bank branch where tax was deposited';
COMMENT ON COLUMN ndfl.tax_payments.minor_head_code IS '100=Advance Tax, 300=Self Assessment Tax, 400=Regular Assessment Tax';
