-- ============================================================
-- Table: alerts
-- Domain: Alerts & Events
-- ============================================================

CREATE TABLE IF NOT EXISTS alerts (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID        NOT NULL,
    symbol_id               UUID,
    alert_type              alert_type  NOT NULL DEFAULT 'price',
    condition               JSONB       NOT NULL DEFAULT '{}',
    notification_channels   TEXT[]      NOT NULL DEFAULT '{in_app}',
    is_active               BOOLEAN     NOT NULL DEFAULT TRUE,
    triggered_count         INTEGER     NOT NULL DEFAULT 0 CHECK (triggered_count >= 0),
    last_triggered_at       TIMESTAMPTZ,
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT alerts_pkey PRIMARY KEY (id),
    CONSTRAINT alerts_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT alerts_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE alerts IS 'User-configured price, volume, technical, and news alerts';
COMMENT ON COLUMN alerts.condition IS 'JSON describing the trigger condition, e.g. {field:"price", op:"gte", value:500}';
COMMENT ON COLUMN alerts.notification_channels IS 'Array of channels to use when triggered: push, email, sms, in_app';
