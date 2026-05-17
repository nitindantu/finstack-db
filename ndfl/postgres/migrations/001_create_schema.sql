-- ============================================================
-- Migration: 001_create_schema
-- Domain: ndfl (tax & compliance platform)
-- Requires: shared schema to be created first
-- ============================================================

CREATE SCHEMA IF NOT EXISTS ndfl;

-- Tax year tracking
\i ndfl/postgres/ddl/001_tax_years.sql

-- Income
\i ndfl/postgres/ddl/002_income_sources.sql
\i ndfl/postgres/ddl/003_capital_gains.sql

-- TDS & Form 26AS
\i ndfl/postgres/ddl/004_tds_records.sql
\i ndfl/postgres/ddl/005_form26as.sql

-- Computation & Payments
\i ndfl/postgres/ddl/006_tax_computations.sql
\i ndfl/postgres/ddl/007_tax_payments.sql

-- Documents
\i ndfl/postgres/ddl/008_tax_documents.sql
