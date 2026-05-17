-- ============================================================
-- Indexes: companies, balance_sheets, income_statements,
--          cash_flows, financial_ratios, earnings
-- ============================================================

-- companies
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_companies_symbol_id
    ON companies (symbol_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_companies_cin
    ON companies (cin)
    WHERE cin IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_companies_name_trgm
    ON companies USING gin (registered_name gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- balance_sheets
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_balance_sheets_company_period
    ON balance_sheets (company_id, period_end_date DESC);

-- income_statements
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_income_statements_company_period
    ON income_statements (company_id, period_end_date DESC);

-- cash_flows
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_cash_flows_company_period
    ON cash_flows (company_id, period_end_date DESC);

-- financial_ratios (hypertable)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_financial_ratios_company_date
    ON financial_ratios (company_id, as_of_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_financial_ratios_symbol_date
    ON financial_ratios (symbol_id, as_of_date DESC);

-- Screener hot columns on financial_ratios
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_financial_ratios_pe_ratio
    ON financial_ratios (pe_ratio)
    WHERE pe_ratio IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_financial_ratios_pb_ratio
    ON financial_ratios (pb_ratio)
    WHERE pb_ratio IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_financial_ratios_roe
    ON financial_ratios (roe)
    WHERE roe IS NOT NULL;

-- earnings
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_earnings_symbol_period
    ON earnings (symbol_id, period_end_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_earnings_report_date
    ON earnings (report_date)
    WHERE report_date IS NOT NULL;

-- shareholding_patterns
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_shareholding_company_period
    ON shareholding_patterns (company_id, period_end_date DESC);

-- analyst_ratings
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analyst_ratings_company
    ON analyst_ratings (company_id, report_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_analyst_ratings_rating
    ON analyst_ratings (rating, report_date DESC);
