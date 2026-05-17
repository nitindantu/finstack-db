-- ============================================================
-- Table: search_logs
-- Domain: Analytics
-- ============================================================

CREATE TABLE IF NOT EXISTS search_logs (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID,
    query               TEXT        NOT NULL,
    search_type         VARCHAR(50) NOT NULL DEFAULT 'stock' CHECK (search_type IN ('stock','screener','news','portfolio','general')),
    results_count       INTEGER     NOT NULL DEFAULT 0 CHECK (results_count >= 0),
    clicked_result_id   UUID,
    response_time_ms    INTEGER     CHECK (response_time_ms IS NULL OR response_time_ms >= 0),
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT search_logs_pkey PRIMARY KEY (id),
    CONSTRAINT search_logs_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT search_logs_query_not_empty CHECK (char_length(query) > 0)
);

COMMENT ON TABLE search_logs IS 'Log of all search queries for relevance tuning and analytics';
COMMENT ON COLUMN search_logs.clicked_result_id IS 'UUID of the result the user clicked; NULL if no click-through';
COMMENT ON COLUMN search_logs.response_time_ms IS 'Elasticsearch/DB query time in milliseconds';
