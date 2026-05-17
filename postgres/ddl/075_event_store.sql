-- ============================================================
-- Table: event_store
-- Domain: Alerts & Events (TimescaleDB hypertable, append-only)
-- ============================================================

CREATE TABLE IF NOT EXISTS event_store (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    aggregate_type  VARCHAR(100) NOT NULL,
    aggregate_id    UUID        NOT NULL,
    event_type      VARCHAR(200) NOT NULL,
    event_data      JSONB       NOT NULL DEFAULT '{}',
    event_version   INTEGER     NOT NULL DEFAULT 1 CHECK (event_version > 0),
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata        JSONB       NOT NULL DEFAULT '{}',

    CONSTRAINT event_store_pkey PRIMARY KEY (id, occurred_at)
);

COMMENT ON TABLE event_store IS 'Append-only domain event log for event-sourcing; TimescaleDB hypertable on occurred_at';
COMMENT ON COLUMN event_store.aggregate_type IS 'Domain aggregate name, e.g. Order, Portfolio, Alert';
COMMENT ON COLUMN event_store.aggregate_id IS 'ID of the aggregate instance this event belongs to';
COMMENT ON COLUMN event_store.event_type IS 'Event class name, e.g. OrderPlaced, PortfolioUpdated, AlertTriggered';
COMMENT ON COLUMN event_store.event_version IS 'Schema version of the event for forward-compatibility';
