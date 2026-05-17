-- ============================================================
-- Table: permissions
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.permissions (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    code            VARCHAR(200) NOT NULL,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    resource        VARCHAR(100) NOT NULL,
    action          VARCHAR(50)  NOT NULL,
    metadata        JSONB        NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT permissions_pkey PRIMARY KEY (id),
    CONSTRAINT permissions_code_unique UNIQUE (code),
    CONSTRAINT permissions_resource_action_unique UNIQUE (resource, action),
    CONSTRAINT permissions_action_format CHECK (action IN ('create','read','update','delete','execute','manage','export','import','share'))
);

COMMENT ON TABLE permissions IS 'Atomic permission definitions; codes are dot-separated resource.action strings';
COMMENT ON COLUMN permissions.code IS 'Machine-readable unique code, e.g. portfolio.create';
COMMENT ON COLUMN permissions.name IS 'Human-readable permission name';
COMMENT ON COLUMN permissions.resource IS 'The resource being guarded, e.g. portfolio, screener, order';
COMMENT ON COLUMN permissions.action IS 'The action permitted on that resource';
