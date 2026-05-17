-- ============================================================
-- Table: devices
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS devices (
    id              UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID            NOT NULL,
    device_token    TEXT            NOT NULL,
    platform        device_platform NOT NULL,
    device_name     VARCHAR(255),
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    last_seen_at    TIMESTAMPTZ,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT devices_pkey PRIMARY KEY (id),
    CONSTRAINT devices_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT devices_token_unique UNIQUE (device_token)
);

COMMENT ON TABLE devices IS 'Registered push-notification device tokens per user';
COMMENT ON COLUMN devices.device_token IS 'FCM/APNs push token; unique across the table';
COMMENT ON COLUMN devices.platform IS 'ios, android, or web (web push)';
COMMENT ON COLUMN devices.last_seen_at IS 'Most recent heartbeat or activity from this device';
