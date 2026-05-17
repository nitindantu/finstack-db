-- ============================================================
-- Table: screener_executions
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screener_executions (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL,
    screener_id         UUID,
    execution_time_ms   INTEGER     NOT NULL CHECK (execution_time_ms >= 0),
    result_count        INTEGER     NOT NULL DEFAULT 0 CHECK (result_count >= 0),
    filters_used        JSONB       NOT NULL DEFAULT '[]',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT screener_executions_pkey PRIMARY KEY (id),
    CONSTRAINT screener_executions_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT screener_executions_screener_fk FOREIGN KEY (screener_id) REFERENCES saved_screeners (id) ON DELETE SET NULL
);

COMMENT ON TABLE screener_executions IS 'Telemetry log of every screener run for performance analytics and usage metering';
COMMENT ON COLUMN screener_executions.execution_time_ms IS 'Wall-clock time taken to execute the screener query in milliseconds';
