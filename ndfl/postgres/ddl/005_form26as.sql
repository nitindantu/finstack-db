-- ============================================================
-- Table: form26as
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- Description: Annual Tax Statement (Form 26AS) data fetched from TRACES
-- ============================================================

CREATE TABLE IF NOT EXISTS ndfl.form26as (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL,
    tax_year_id         UUID NOT NULL,
    deductor_name       VARCHAR(255) NOT NULL,
    deductor_tan        VARCHAR(10),
    section_code        VARCHAR(10),
    transaction_date    DATE NOT NULL,
    amount              NUMERIC(18, 2) NOT NULL,
    tds_amount          NUMERIC(18, 2) NOT NULL,
    tds_deposited       NUMERIC(18, 2),
    booking_status      VARCHAR(50),                -- F (Final), U (Unmatched), P (Provisional)
    certificate_number  VARCHAR(50),
    remarks             TEXT,
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT form26as_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT form26as_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.form26as IS 'Form 26AS annual tax statement data from TRACES';
COMMENT ON COLUMN ndfl.form26as.booking_status IS 'F=Final, U=Unmatched, P=Provisional, O=Overbooked';
