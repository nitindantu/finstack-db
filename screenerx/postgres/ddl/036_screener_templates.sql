-- ============================================================
-- Table: screener_templates
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.screener_templates (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    tenant_id       UUID        NOT NULL,
    user_id         UUID        NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_public       BOOLEAN     NOT NULL DEFAULT FALSE,
    is_system       BOOLEAN     NOT NULL DEFAULT FALSE,
    category        VARCHAR(100),
    filters         JSONB       NOT NULL DEFAULT '[]',
    sort_by         VARCHAR(100),
    sort_order      VARCHAR(4)  NOT NULL DEFAULT 'desc' CHECK (sort_order IN ('asc','desc')),
    columns         TEXT[]      NOT NULL DEFAULT '{}',
    use_count       INTEGER     NOT NULL DEFAULT 0 CHECK (use_count >= 0),
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT screener_templates_pkey PRIMARY KEY (id),
    CONSTRAINT screener_templates_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT screener_templates_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE screener_templates IS 'Reusable stock screener filter templates with saved column layouts';
COMMENT ON COLUMN screener_templates.filters IS 'JSON array of filter objects {field, operator, value}';
COMMENT ON COLUMN screener_templates.columns IS 'Ordered list of column keys to display in results';
COMMENT ON COLUMN screener_templates.use_count IS 'Number of times this template has been run';
COMMENT ON COLUMN screener_templates.is_system IS 'TRUE for platform-curated screeners available to all users';
