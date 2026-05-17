-- ============================================================
-- Table: billing_transactions
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.billing_transactions (
    id                          UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id                     UUID            NOT NULL,
    subscription_id             UUID,
    amount                      NUMERIC(12,2)   NOT NULL,
    currency                    CHAR(3)         NOT NULL DEFAULT 'INR',
    status                      billing_status  NOT NULL DEFAULT 'pending',
    stripe_payment_intent_id    VARCHAR(255),
    stripe_invoice_id           VARCHAR(255),
    description                 TEXT,
    metadata                    JSONB           NOT NULL DEFAULT '{}',
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ,
    created_by                  UUID,
    updated_by                  UUID,

    CONSTRAINT billing_transactions_pkey PRIMARY KEY (id),
    CONSTRAINT billing_transactions_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE RESTRICT,
    CONSTRAINT billing_transactions_subscription_fk FOREIGN KEY (subscription_id) REFERENCES shared.subscriptions (id) ON DELETE SET NULL,
    CONSTRAINT billing_transactions_amount_positive CHECK (amount > 0),
    CONSTRAINT billing_transactions_currency_format CHECK (currency ~ '^[A-Z]{3}$')
);

COMMENT ON TABLE billing_transactions IS 'Individual payment and refund events tied to subscriptions';
COMMENT ON COLUMN billing_transactions.amount IS 'Transaction amount in minor units of the stated currency';
COMMENT ON COLUMN billing_transactions.stripe_payment_intent_id IS 'Stripe PaymentIntent ID (pi_xxx)';
COMMENT ON COLUMN billing_transactions.stripe_invoice_id IS 'Stripe Invoice ID (in_xxx)';
