-- ============================================================
-- Table: screener_results_cache
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.screener_results_cache (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    screener_hash   VARCHAR(64) NOT NULL,
    symbol_ids      UUID[]      NOT NULL DEFAULT '{}',
    result_data     JSONB       NOT NULL DEFAULT '{}',
    executed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ NOT NULL,

    CONSTRAINT screener_results_cache_pkey PRIMARY KEY (id),
    CONSTRAINT screener_results_cache_hash_unique UNIQUE (screener_hash),
    CONSTRAINT screener_results_cache_expires_after CHECK (expires_at > executed_at)
);

COMMENT ON TABLE screener_results_cache IS 'Short-lived cache of screener execution results keyed by filter hash';
COMMENT ON COLUMN screener_results_cache.screener_hash IS 'SHA-256 hash of the canonical JSON representation of the filter set';
COMMENT ON COLUMN screener_results_cache.result_data IS 'Full result set including metric values for each matched symbol';
