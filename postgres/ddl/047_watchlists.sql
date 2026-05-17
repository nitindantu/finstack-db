-- ============================================================
-- Table: watchlists
-- Domain: Portfolio
-- ============================================================

CREATE TABLE IF NOT EXISTS watchlists (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    is_default      BOOLEAN     NOT NULL DEFAULT FALSE,
    is_public       BOOLEAN     NOT NULL DEFAULT FALSE,
    item_count      INTEGER     NOT NULL DEFAULT 0 CHECK (item_count >= 0),
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT watchlists_pkey PRIMARY KEY (id),
    CONSTRAINT watchlists_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT watchlists_name_user_unique UNIQUE (user_id, name)
);

COMMENT ON TABLE watchlists IS 'Named lists of instruments that users want to track';
COMMENT ON COLUMN watchlists.is_default IS 'TRUE for the user''s primary watchlist shown on login';
COMMENT ON COLUMN watchlists.item_count IS 'Denormalised count maintained by trigger for fast display';
