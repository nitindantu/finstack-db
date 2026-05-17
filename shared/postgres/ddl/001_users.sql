-- ============================================================
-- Table: users
-- Domain: User & Auth
-- ============================================================

CREATE TABLE IF NOT EXISTS shared.users (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    tenant_id           UUID        NOT NULL,
    email               VARCHAR(320) NOT NULL,
    password_hash       TEXT,
    full_name           VARCHAR(255) NOT NULL,
    phone               VARCHAR(20),
    avatar_url          TEXT,
    email_verified      BOOLEAN     NOT NULL DEFAULT FALSE,
    phone_verified      BOOLEAN     NOT NULL DEFAULT FALSE,
    status              user_status NOT NULL DEFAULT 'active',
    plan_type           plan_type   NOT NULL DEFAULT 'free',
    last_login_at       TIMESTAMPTZ,
    login_count         INTEGER     NOT NULL DEFAULT 0 CHECK (login_count >= 0),
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,

    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_email_tenant_unique UNIQUE (email, tenant_id),
    CONSTRAINT users_email_format CHECK (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT users_phone_format CHECK (phone IS NULL OR phone ~ '^\+?[0-9\s\-\(\)]{7,20}$'),
    CONSTRAINT users_login_count_non_negative CHECK (login_count >= 0)
);

COMMENT ON TABLE users IS 'Core user accounts for all tenants in the ScreenerX platform';
COMMENT ON COLUMN users.id IS 'Unique user identifier (UUID v4)';
COMMENT ON COLUMN users.tenant_id IS 'Tenant/organization this user belongs to';
COMMENT ON COLUMN users.email IS 'User email address, unique per tenant';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt or argon2 hash of password; NULL for OAuth-only users';
COMMENT ON COLUMN users.full_name IS 'Display name of the user';
COMMENT ON COLUMN users.phone IS 'E.164 format phone number';
COMMENT ON COLUMN users.avatar_url IS 'URL to profile picture';
COMMENT ON COLUMN users.email_verified IS 'Whether the email has been confirmed via OTP/link';
COMMENT ON COLUMN users.phone_verified IS 'Whether phone has been confirmed via OTP';
COMMENT ON COLUMN users.status IS 'Account lifecycle status';
COMMENT ON COLUMN users.plan_type IS 'Current subscription plan';
COMMENT ON COLUMN users.last_login_at IS 'Timestamp of most recent successful login';
COMMENT ON COLUMN users.login_count IS 'Running count of successful logins';
COMMENT ON COLUMN users.metadata IS 'Flexible JSON bag for additional attributes';
COMMENT ON COLUMN users.created_at IS 'Row creation timestamp';
COMMENT ON COLUMN users.updated_at IS 'Row last-modification timestamp';
COMMENT ON COLUMN users.deleted_at IS 'Soft-delete timestamp; NULL means active';
