-- ============================================================
-- Table: capital_gains
-- Domain: NDFL / Tax & Compliance
-- Schema: ndfl
-- ============================================================

CREATE TYPE IF NOT EXISTS ndfl.capital_asset_type_enum AS ENUM (
    'equity',
    'mutual_fund',
    'property',
    'gold',
    'crypto',
    'bonds',
    'other'
);

CREATE TYPE IF NOT EXISTS ndfl.gain_type_enum AS ENUM (
    'stcg',   -- Short-Term Capital Gain
    'ltcg'    -- Long-Term Capital Gain
);

CREATE TABLE IF NOT EXISTS ndfl.capital_gains (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tax_year_id                     UUID NOT NULL,
    user_id                         UUID NOT NULL,
    asset_type                      ndfl.capital_asset_type_enum NOT NULL,
    asset_name                      VARCHAR(255),
    isin                            VARCHAR(12),
    purchase_date                   DATE NOT NULL,
    sale_date                       DATE NOT NULL,
    purchase_price                  NUMERIC(18, 4) NOT NULL,
    sale_price                      NUMERIC(18, 4) NOT NULL,
    quantity                        NUMERIC(18, 4) NOT NULL,
    purchase_cost                   NUMERIC(18, 2) NOT NULL,     -- purchase_price * quantity + charges
    sale_proceeds                   NUMERIC(18, 2) NOT NULL,     -- sale_price * quantity - charges
    indexed_cost                    NUMERIC(18, 2),              -- for LTCG with indexation
    gain_amount                     NUMERIC(18, 2) NOT NULL,     -- sale_proceeds - purchase_cost (or indexed_cost)
    gain_type                       ndfl.gain_type_enum NOT NULL,
    tax_rate                        NUMERIC(5, 2),               -- applicable tax rate %
    tax_amount                      NUMERIC(18, 2),
    stt_paid                        BOOLEAN NOT NULL DEFAULT false,
    grandfathering_applicable       BOOLEAN NOT NULL DEFAULT false,
    fair_market_value_jan2018       NUMERIC(18, 4),              -- for equity LTCG grandfathering
    broker_name                     VARCHAR(255),
    metadata                        JSONB DEFAULT '{}',
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at                      TIMESTAMPTZ,

    CONSTRAINT capital_gains_tax_year_fk FOREIGN KEY (tax_year_id) REFERENCES ndfl.tax_years (id) ON DELETE CASCADE,
    CONSTRAINT capital_gains_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE
);

COMMENT ON TABLE ndfl.capital_gains IS 'Capital gains transactions for tax computation';
COMMENT ON COLUMN ndfl.capital_gains.grandfathering_applicable IS 'Equity LTCG grandfathering rule for assets held before Feb 1, 2018';
