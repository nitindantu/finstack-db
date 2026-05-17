-- ============================================================
-- Triggers: orders table
-- ============================================================

-- Auto-update updated_at
DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Audit log on status change
CREATE OR REPLACE FUNCTION orders_status_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO audit_logs (
            tenant_id, user_id, action, resource_type, resource_id,
            old_values, new_values
        )
        SELECT
            COALESCE(u.tenant_id, '00000000-0000-0000-0000-000000000000'::UUID),
            NEW.user_id,
            'order.status_changed',
            'orders',
            NEW.id,
            jsonb_build_object('status', OLD.status, 'updated_at', OLD.updated_at),
            jsonb_build_object('status', NEW.status, 'updated_at', NEW.updated_at,
                               'broker_order_id', NEW.broker_order_id,
                               'exchange_order_id', NEW.exchange_order_id)
        FROM users u WHERE u.id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_orders_status_audit ON orders;
CREATE TRIGGER trg_orders_status_audit
    AFTER UPDATE OF status ON orders
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION orders_status_audit();

-- Set placed_at when status transitions from pending to open
CREATE OR REPLACE FUNCTION orders_set_timestamps()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = 'open' AND OLD.status = 'pending' AND NEW.placed_at IS NULL THEN
        NEW.placed_at := NOW();
    END IF;
    IF NEW.status = 'filled' AND OLD.status != 'filled' AND NEW.executed_at IS NULL THEN
        NEW.executed_at := NOW();
    END IF;
    IF NEW.status IN ('cancelled', 'rejected') AND NEW.cancelled_at IS NULL THEN
        NEW.cancelled_at := NOW();
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_orders_set_timestamps ON orders;
CREATE TRIGGER trg_orders_set_timestamps
    BEFORE UPDATE OF status ON orders
    FOR EACH ROW EXECUTE FUNCTION orders_set_timestamps();
