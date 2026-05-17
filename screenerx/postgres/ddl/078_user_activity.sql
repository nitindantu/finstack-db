-- ============================================================
-- Table: user_activity
-- Domain: Analytics (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.user_activity (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    action_type     VARCHAR(100) NOT NULL,
    page            VARCHAR(200),
    resource_type   VARCHAR(100),
    resource_id     UUID,
    duration_ms     INTEGER     CHECK (duration_ms IS NULL OR duration_ms >= 0),
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_activity_pkey PRIMARY KEY (id, created_at),
    CONSTRAINT user_activity_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE
);

COMMENT ON TABLE user_activity IS 'Fine-grained user behavioural event stream; TimescaleDB hypertable on created_at';
COMMENT ON COLUMN user_activity.action_type IS 'Event name, e.g. page_view, screener_run, chart_open, order_placed';
COMMENT ON COLUMN user_activity.page IS 'URL path or page name where the action occurred';
COMMENT ON COLUMN user_activity.duration_ms IS 'Time spent on the page/feature in milliseconds';
