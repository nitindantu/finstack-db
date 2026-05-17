-- ============================================================
-- Table: user_preferences
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.user_preferences (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID        NOT NULL,
    theme                   VARCHAR(20) NOT NULL DEFAULT 'system' CHECK (theme IN ('light','dark','system')),
    language                VARCHAR(10) NOT NULL DEFAULT 'en',
    timezone                VARCHAR(60) NOT NULL DEFAULT 'Asia/Kolkata',
    currency                CHAR(3)     NOT NULL DEFAULT 'INR',
    notification_settings   JSONB       NOT NULL DEFAULT '{"email":true,"push":true,"sms":false,"in_app":true}',
    dashboard_layout        JSONB       NOT NULL DEFAULT '{}',
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT user_preferences_pkey PRIMARY KEY (id),
    CONSTRAINT user_preferences_user_unique UNIQUE (user_id),
    CONSTRAINT user_preferences_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT user_preferences_currency_format CHECK (currency ~ '^[A-Z]{3}$')
);

COMMENT ON TABLE user_preferences IS 'Per-user UI and notification preference store; exactly one row per user';
COMMENT ON COLUMN user_preferences.theme IS 'UI color theme: light, dark, or follow system preference';
COMMENT ON COLUMN user_preferences.timezone IS 'IANA timezone identifier, e.g. Asia/Kolkata';
COMMENT ON COLUMN user_preferences.notification_settings IS 'Channel-level notification opt-in/out flags';
COMMENT ON COLUMN user_preferences.dashboard_layout IS 'Serialized dashboard widget arrangement';
