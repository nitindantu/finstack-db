-- ============================================================
-- Table: tds_records
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.tds_form_type_enum AS ENUM (
    '16',
    '16A',
    '26Q',
    '27Q'
);

CREATE TABLE IF NOT EXISTS ndfl.tds_records (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,
    deductor_name       VARCHAR(255) NOT NULL,
    deductor_tan        VARCHAR(10),
    deductor_pan        VARCHAR(10),
    section_code        VARCHAR(10) NOT NULL,       -- e.g. 192, 194C, 194J
    payment_date        DATE NOT NULL,
    amount_paid         NUMERIC(18, 2) NOT NULL,
    tds_deducted        NUMERIC(18, 2) NOT NULL,
    tds_deposited       NUMERIC(18, 2),
    certificate_number  VARCHAR(50),
    form_type           ndfl.tds_form_type_enum,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,

    CONSTRAINT tds_records_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT tds_records_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.tds_records IS 'Tax Deducted at Source records from deductors';
COMMENT ON COLUMN ndfl.tds_records.section_code IS 'Income Tax Act section under which TDS is deducted, e.g. 192 (salary), 194C (contractor), 194J (professional)';
