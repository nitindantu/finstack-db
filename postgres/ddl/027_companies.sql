-- ============================================================
-- Table: companies
-- Domain: Company Fundamentals
-- ============================================================

CREATE TABLE IF NOT EXISTS companies (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    symbol_id           UUID        NOT NULL,
    cin                 VARCHAR(21),
    pan                 VARCHAR(10),
    registered_name     VARCHAR(500) NOT NULL,
    about               TEXT,
    website             TEXT,
    founded_year        SMALLINT    CHECK (founded_year IS NULL OR (founded_year >= 1800 AND founded_year <= EXTRACT(YEAR FROM NOW())::INT)),
    employee_count      INTEGER     CHECK (employee_count IS NULL OR employee_count >= 0),
    headquarters        VARCHAR(500),
    promoter_names      TEXT[]      NOT NULL DEFAULT '{}',
    management          JSONB       NOT NULL DEFAULT '[]',
    subsidiaries        JSONB       NOT NULL DEFAULT '[]',
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT companies_pkey PRIMARY KEY (id),
    CONSTRAINT companies_symbol_unique UNIQUE (symbol_id),
    CONSTRAINT companies_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE RESTRICT,
    CONSTRAINT companies_cin_format CHECK (cin IS NULL OR cin ~ '^[A-Z][0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$'),
    CONSTRAINT companies_pan_format CHECK (pan IS NULL OR pan ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')
);

COMMENT ON TABLE companies IS 'Fundamental company information tied to a listed symbol';
COMMENT ON COLUMN companies.cin IS 'Corporate Identification Number (21-char Indian MCA format)';
COMMENT ON COLUMN companies.pan IS 'Permanent Account Number (10-char Indian Income Tax identifier)';
COMMENT ON COLUMN companies.management IS 'JSON array of {name, designation, since} objects for key executives';
COMMENT ON COLUMN companies.subsidiaries IS 'JSON array of {name, stake_pct, cin} objects for subsidiaries';
