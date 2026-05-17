-- ============================================================
-- Function: set_updated_at()
-- Automatically updates the updated_at column on row modification
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION set_updated_at() IS 'Generic trigger function to auto-update updated_at timestamp on row modification';


-- ============================================================
-- Function: write_audit_log()
-- Generic trigger function that writes to audit_logs on INSERT/UPDATE/DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION write_audit_log()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant_id     UUID;
    v_user_id       UUID;
    v_resource_id   UUID;
    v_action        TEXT;
    v_old_values    JSONB;
    v_new_values    JSONB;
BEGIN
    -- Determine action string
    IF TG_OP = 'INSERT' THEN
        v_action      := lower(TG_TABLE_NAME) || '.created';
        v_old_values  := NULL;
        v_new_values  := to_jsonb(NEW);
        v_resource_id := (to_jsonb(NEW)->>'id')::UUID;
    ELSIF TG_OP = 'UPDATE' THEN
        v_action      := lower(TG_TABLE_NAME) || '.updated';
        v_old_values  := to_jsonb(OLD);
        v_new_values  := to_jsonb(NEW);
        v_resource_id := (to_jsonb(NEW)->>'id')::UUID;
    ELSIF TG_OP = 'DELETE' THEN
        v_action      := lower(TG_TABLE_NAME) || '.deleted';
        v_old_values  := to_jsonb(OLD);
        v_new_values  := NULL;
        v_resource_id := (to_jsonb(OLD)->>'id')::UUID;
    END IF;

    -- Safely extract tenant_id and user_id if columns exist
    BEGIN
        v_tenant_id := COALESCE(
            (to_jsonb(COALESCE(NEW, OLD))->>'tenant_id')::UUID,
            NULL
        );
    EXCEPTION WHEN OTHERS THEN
        v_tenant_id := NULL;
    END;

    BEGIN
        v_user_id := COALESCE(
            (to_jsonb(COALESCE(NEW, OLD))->>'user_id')::UUID,
            (to_jsonb(COALESCE(NEW, OLD))->>'updated_by')::UUID,
            NULL
        );
    EXCEPTION WHEN OTHERS THEN
        v_user_id := NULL;
    END;

    -- Write audit record (fire-and-forget; never block the main transaction)
    INSERT INTO audit_logs (tenant_id, user_id, action, resource_type, resource_id, old_values, new_values)
    VALUES (
        COALESCE(v_tenant_id, '00000000-0000-0000-0000-000000000000'::UUID),
        v_user_id,
        v_action,
        TG_TABLE_NAME,
        v_resource_id,
        v_old_values,
        v_new_values
    );

    RETURN COALESCE(NEW, OLD);
EXCEPTION
    WHEN OTHERS THEN
        -- Never let audit failures break the main transaction
        RETURN COALESCE(NEW, OLD);
END;
$$;

COMMENT ON FUNCTION write_audit_log() IS 'Generic trigger function that records all INSERT/UPDATE/DELETE events to audit_logs';


-- ============================================================
-- Function: prevent_hard_delete()
-- Prevents physical DELETE; use soft delete (deleted_at) instead
-- ============================================================

CREATE OR REPLACE FUNCTION prevent_hard_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Hard deletes are not allowed on %. Use soft delete (set deleted_at = NOW()) instead.', TG_TABLE_NAME
        USING ERRCODE = 'P0001';
END;
$$;

COMMENT ON FUNCTION prevent_hard_delete() IS 'Raises an exception to prevent physical DELETE operations; enforce soft-delete pattern';
