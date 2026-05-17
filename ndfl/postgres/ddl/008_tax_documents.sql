-- ============================================================
-- Table: tax_documents
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.tax_document_type_enum AS ENUM (
    'form16',
    'form16a',
    'form26as',
    'itr_ack',
    'computation_sheet',
    'capital_gains_statement',
    'other'
);

CREATE TABLE IF NOT EXISTS ndfl.tax_documents (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    tax_year_id     UUID NOT NULL,
    document_type   ndfl.tax_document_type_enum NOT NULL,
    file_name       VARCHAR(500) NOT NULL,
    file_path       TEXT NOT NULL,
    file_size       BIGINT,                         -- size in bytes
    mime_type       VARCHAR(100),
    uploaded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    verified_at     TIMESTAMPTZ,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT tax_documents_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT tax_documents_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.tax_documents IS 'Tax-related documents uploaded by users (Form 16, ITR acknowledgements, etc.)';
