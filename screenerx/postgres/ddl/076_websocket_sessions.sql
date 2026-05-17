-- ============================================================
-- Table: websocket_sessions
-- Domain: Alerts & Events
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.websocket_sessions (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL,
    connection_id       VARCHAR(255) NOT NULL,
    subscriptions       JSONB       NOT NULL DEFAULT '[]',
    connected_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    disconnected_at     TIMESTAMPTZ,
    messages_sent       BIGINT      NOT NULL DEFAULT 0 CHECK (messages_sent >= 0),
    messages_received   BIGINT      NOT NULL DEFAULT 0 CHECK (messages_received >= 0),
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT websocket_sessions_pkey PRIMARY KEY (id),
    CONSTRAINT websocket_sessions_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT websocket_sessions_connection_id_unique UNIQUE (connection_id),
    CONSTRAINT websocket_sessions_disconnected_after_connected CHECK (
        disconnected_at IS NULL OR disconnected_at >= connected_at
    )
);

COMMENT ON TABLE websocket_sessions IS 'Active and historical WebSocket connection sessions for real-time data delivery';
COMMENT ON COLUMN websocket_sessions.connection_id IS 'Unique connection identifier assigned by WebSocket gateway';
COMMENT ON COLUMN websocket_sessions.subscriptions IS 'JSON array of channel/topic subscriptions for this connection';
