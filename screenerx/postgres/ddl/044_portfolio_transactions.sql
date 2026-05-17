-- ============================================================
-- Table: portfolio_transactions
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.portfolio_transactions (
    id                  UUID                NOT NULL DEFAULT gen_random_uuid(),
    portfolio_id        UUID                NOT NULL,
    symbol_id           UUID                NOT NULL,
    transaction_type    transaction_type    NOT NULL,
    transaction_date    DATE                NOT NULL,
    quantity            NUMERIC(18,6)       NOT NULL CHECK (quantity > 0),
    price               NUMERIC(18,6)       NOT NULL CHECK (price >= 0),
    amount              NUMERIC(20,2)       NOT NULL,
    charges             NUMERIC(12,4)       NOT NULL DEFAULT 0 CHECK (charges >= 0),
    taxes               NUMERIC(12,4)       NOT NULL DEFAULT 0 CHECK (taxes >= 0),
    net_amount          NUMERIC(20,2)       NOT NULL,
    notes               TEXT,
    broker_ref          VARCHAR(100),
    metadata            JSONB               NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT portfolio_transactions_pkey PRIMARY KEY (id),
    CONSTRAINT portfolio_transactions_portfolio_fk FOREIGN KEY (portfolio_id) REFERENCES screenerx.portfolios (id) ON DELETE CASCADE,
    CONSTRAINT portfolio_transactions_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE RESTRICT
);

COMMENT ON TABLE portfolio_transactions IS 'All buy/sell/corporate action transactions in a portfolio';
COMMENT ON COLUMN portfolio_transactions.amount IS 'Gross transaction value (quantity * price)';
COMMENT ON COLUMN portfolio_transactions.net_amount IS 'amount + charges + taxes for buys; amount - charges - taxes for sells';
COMMENT ON COLUMN portfolio_transactions.broker_ref IS 'Broker-assigned order/trade reference number';
