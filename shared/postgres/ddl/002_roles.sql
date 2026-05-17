-- ============================================================
-- Table: roles
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.roles (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    tenant_id       UUID        NOT NULL,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    is_system       BOOLEAN     NOT NULL DEFAULT FALSE,
    permissions     JSONB       NOT NULL DEFAULT '[]',
    metadata        JSONB       NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    created_by      UUID,
    updated_by      UUID,

    CONSTRAINT roles_pkey PRIMARY KEY (id),
    CONSTRAINT roles_name_tenant_unique UNIQUE (name, tenant_id)
);

COMMENT ON TABLE roles IS 'RBAC roles that can be assigned to users within a tenant';
COMMENT ON COLUMN roles.id IS 'Unique role identifier';
COMMENT ON COLUMN roles.tenant_id IS 'Tenant that owns this role; system roles span all tenants';
COMMENT ON COLUMN roles.name IS 'Human-readable role name, unique per tenant';
COMMENT ON COLUMN roles.description IS 'What this role grants access to';
COMMENT ON COLUMN roles.is_system IS 'TRUE for built-in platform roles that cannot be deleted';
COMMENT ON COLUMN roles.permissions IS 'JSON array of permission codes bundled in this role';
COMMENT ON COLUMN roles.metadata IS 'Flexible JSON bag for additional attributes';
