-- ============================================================
-- Table: baskets
-- Domain: Trading / Basket Orders
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================
-- A basket is a named collection of orders executed together.
-- Items are placed sequentially with a 100 ms delay between legs
-- to avoid exchange throttling.
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.baskets (
    id          UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id     UUID            NOT NULL,
    name        VARCHAR(255)    NOT NULL,
    description TEXT,
    status      VARCHAR(25)     NOT NULL DEFAULT 'draft',
    -- draft | executing | executed | partially_executed | failed
    executed_at TIMESTAMPTZ,
    metadata    JSONB           NOT NULL DEFAULT '{}',
    -- metadata.broker_account_id is set at basket creation
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT baskets_pkey PRIMARY KEY (id),
    CONSTRAINT baskets_user_fk FOREIGN KEY (user_id)
        REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT baskets_status_check CHECK (
        status IN ('draft','executing','executed','partially_executed','failed')
    )
);

CREATE INDEX IF NOT EXISTS idx_baskets_user
    ON screenerx.baskets (user_id, created_at DESC);
