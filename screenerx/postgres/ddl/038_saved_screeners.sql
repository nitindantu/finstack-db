-- ============================================================
-- Table: saved_screeners
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.saved_screeners (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    template_id     UUID        NOT NULL,
    name            VARCHAR(255) NOT NULL,
    last_run_at     TIMESTAMPTZ,
    result_count    INTEGER     CHECK (result_count IS NULL OR result_count >= 0),
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT saved_screeners_pkey PRIMARY KEY (id),
    CONSTRAINT saved_screeners_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT saved_screeners_template_fk FOREIGN KEY (template_id) REFERENCES screenerx.screener_templates (id) ON DELETE RESTRICT,
    CONSTRAINT saved_screeners_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE saved_screeners IS 'User''s personal saved screener instances with run history';
