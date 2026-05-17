-- ============================================================
-- Table: alert_events
-- Domain: Alerts & Events (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.alert_events (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    alert_id                UUID        NOT NULL,
    triggered_at            TIMESTAMPTZ NOT NULL,
    trigger_value           NUMERIC(20,6),
    message                 TEXT        NOT NULL,
    was_notified            BOOLEAN     NOT NULL DEFAULT FALSE,
    notification_results    JSONB       NOT NULL DEFAULT '{}',
    metadata                JSONB       NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT alert_events_pkey PRIMARY KEY (id, triggered_at),
    CONSTRAINT alert_events_alert_fk FOREIGN KEY (alert_id) REFERENCES screenerx.alerts (id) ON DELETE CASCADE
);

COMMENT ON TABLE alert_events IS 'Individual trigger firings of an alert; TimescaleDB hypertable on triggered_at';
COMMENT ON COLUMN alert_events.trigger_value IS 'The actual value that caused the alert to fire (e.g. the price)';
COMMENT ON COLUMN alert_events.notification_results IS 'JSON: {email:{status,error}, push:{status,error}, ...}';
