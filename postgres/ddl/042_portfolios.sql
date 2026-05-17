-- ============================================================
-- Table: portfolios
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS portfolios (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL,
    tenant_id           UUID            NOT NULL,
    name                VARCHAR(255)    NOT NULL,
    description         TEXT,
    currency            CHAR(3)         NOT NULL DEFAULT 'INR',
    benchmark_symbol    VARCHAR(50),
    portfolio_type      portfolio_type  NOT NULL DEFAULT 'real',
    broker_account_id   UUID,
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    inception_date      DATE            NOT NULL DEFAULT CURRENT_DATE,
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT portfolios_pkey PRIMARY KEY (id),
    CONSTRAINT portfolios_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT portfolios_currency_format CHECK (currency ~ '^[A-Z]{3}$'),
    CONSTRAINT portfolios_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE portfolios IS 'Investment portfolio containers; can be real, paper-trading, or model portfolios';
COMMENT ON COLUMN portfolios.portfolio_type IS 'real = live money, paper = simulated, model = theoretical';
COMMENT ON COLUMN portfolios.benchmark_symbol IS 'Ticker of benchmark index for performance comparison (e.g. NIFTY50)';
COMMENT ON COLUMN portfolios.inception_date IS 'Date from which performance metrics are calculated';
