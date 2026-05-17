-- ============================================================
-- Table: custom_formulas
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.custom_formulas (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL,
    name            VARCHAR(255) NOT NULL,
    expression      TEXT        NOT NULL,
    description     TEXT,
    variables       JSONB       NOT NULL DEFAULT '{}',
    is_public       BOOLEAN     NOT NULL DEFAULT FALSE,
    test_result     JSONB,
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT custom_formulas_pkey PRIMARY KEY (id),
    CONSTRAINT custom_formulas_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT custom_formulas_name_user_unique UNIQUE (user_id, name),
    CONSTRAINT custom_formulas_expression_not_empty CHECK (char_length(expression) > 0)
);

COMMENT ON TABLE custom_formulas IS 'User-defined computed metric formulas for use in screener filters';
COMMENT ON COLUMN custom_formulas.expression IS 'Formula string using field names and arithmetic, e.g. revenue / market_cap';
COMMENT ON COLUMN custom_formulas.variables IS 'JSON map of variable name to field path for formula substitution';
COMMENT ON COLUMN custom_formulas.test_result IS 'Last test execution result for formula validation';
