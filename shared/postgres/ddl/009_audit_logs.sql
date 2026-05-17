-- ============================================================
-- Table: audit_logs
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.audit_logs (
    id              UUID        NOT NULL DEFAULT gen_random_uuid(),
    tenant_id       UUID        NOT NULL,
    user_id         UUID,
    action          VARCHAR(100) NOT NULL,
    resource_type   VARCHAR(100) NOT NULL,
    resource_id     UUID,
    old_values      JSONB,
    new_values      JSONB,
    ip_address      INET,
    user_agent      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT audit_logs_pkey PRIMARY KEY (id),
    CONSTRAINT audit_logs_action_not_empty CHECK (char_length(action) > 0)
);

COMMENT ON TABLE audit_logs IS 'Immutable audit trail of all significant data-changing operations';
COMMENT ON COLUMN audit_logs.action IS 'Verb describing the operation, e.g. user.login, order.cancel';
COMMENT ON COLUMN audit_logs.resource_type IS 'Table/entity name that was mutated';
COMMENT ON COLUMN audit_logs.resource_id IS 'Primary key of the mutated row';
COMMENT ON COLUMN audit_logs.old_values IS 'JSON snapshot of changed fields before the operation';
COMMENT ON COLUMN audit_logs.new_values IS 'JSON snapshot of changed fields after the operation';
