-- ============================================================
-- Table: notifications
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS notifications (
    id              UUID                NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL,
    type            notification_type   NOT NULL DEFAULT 'system',
    title           VARCHAR(500)        NOT NULL,
    body            TEXT                NOT NULL,
    data            JSONB               NOT NULL DEFAULT '{}',
    read_at         TIMESTAMPTZ,
    sent_at         TIMESTAMPTZ,
    channel         notification_channel NOT NULL DEFAULT 'in_app',
    metadata        JSONB               NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT notifications_pkey PRIMARY KEY (id),
    CONSTRAINT notifications_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

COMMENT ON TABLE notifications IS 'In-app and push/email/SMS notification records per user';
COMMENT ON COLUMN notifications.type IS 'Notification category for display and routing';
COMMENT ON COLUMN notifications.data IS 'Arbitrary payload attached to the notification (e.g. stock ticker, alert id)';
COMMENT ON COLUMN notifications.read_at IS 'Timestamp the user marked this notification as read; NULL = unread';
COMMENT ON COLUMN notifications.sent_at IS 'When the notification was dispatched to the delivery channel';
COMMENT ON COLUMN notifications.channel IS 'Delivery channel used for this specific record';
