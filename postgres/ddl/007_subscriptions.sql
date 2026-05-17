-- ============================================================
-- Table: subscriptions
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS subscriptions (
    id                          UUID                NOT NULL DEFAULT gen_random_uuid(),
    user_id                     UUID                NOT NULL,
    plan_type                   plan_type           NOT NULL DEFAULT 'free',
    status                      subscription_status NOT NULL DEFAULT 'active',
    stripe_subscription_id      VARCHAR(255),
    stripe_customer_id          VARCHAR(255),
    current_period_start        TIMESTAMPTZ,
    current_period_end          TIMESTAMPTZ,
    cancel_at_period_end        BOOLEAN             NOT NULL DEFAULT FALSE,
    trial_end                   TIMESTAMPTZ,
    metadata                    JSONB               NOT NULL DEFAULT '{}',
    created_at                  TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at                  TIMESTAMPTZ,
    created_by                  UUID,
    updated_by                  UUID,

    CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
    CONSTRAINT subscriptions_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT subscriptions_stripe_sub_unique UNIQUE (stripe_subscription_id),
    CONSTRAINT subscriptions_period_check CHECK (current_period_end IS NULL OR current_period_end > current_period_start)
);

COMMENT ON TABLE subscriptions IS 'Stripe-backed subscription records for each user';
COMMENT ON COLUMN subscriptions.stripe_subscription_id IS 'Stripe subscription object ID (sub_xxx)';
COMMENT ON COLUMN subscriptions.stripe_customer_id IS 'Stripe customer object ID (cus_xxx)';
COMMENT ON COLUMN subscriptions.cancel_at_period_end IS 'TRUE means subscription will not renew at end of current period';
COMMENT ON COLUMN subscriptions.trial_end IS 'When trial ends; NULL if no trial';
