-- ============================================================
-- Table: user_roles
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.user_roles (
    id          UUID        NOT NULL DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL,
    role_id     UUID        NOT NULL,
    granted_by  UUID,
    granted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT user_roles_pkey PRIMARY KEY (id),
    CONSTRAINT user_roles_user_role_unique UNIQUE (user_id, role_id),
    CONSTRAINT user_roles_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT user_roles_role_fk FOREIGN KEY (role_id) REFERENCES shared.roles (id) ON DELETE CASCADE,
    CONSTRAINT user_roles_granted_by_fk FOREIGN KEY (granted_by) REFERENCES shared.users (id) ON DELETE SET NULL,
    CONSTRAINT user_roles_expires_after_grant CHECK (expires_at IS NULL OR expires_at > granted_at)
);

COMMENT ON TABLE user_roles IS 'Many-to-many mapping of users to roles with optional expiry';
COMMENT ON COLUMN user_roles.granted_by IS 'Admin user who assigned this role';
COMMENT ON COLUMN user_roles.expires_at IS 'NULL means role never expires for this user';
