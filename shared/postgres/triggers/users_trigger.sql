-- ============================================================
-- Triggers: users table
-- ============================================================

-- Auto-update updated_at
DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Write audit log on insert/update (NOT on delete — hard deletes are prevented)
DROP TRIGGER IF EXISTS trg_users_audit ON users;
CREATE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION write_audit_log();

-- Auto-create user_preferences row when a new user is inserted
CREATE OR REPLACE FUNCTION create_default_user_preferences()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO user_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_create_preferences ON users;
CREATE TRIGGER trg_users_create_preferences
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_default_user_preferences();
