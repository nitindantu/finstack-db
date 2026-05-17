-- ============================================================
-- Triggers: alerts / alert_events
-- ============================================================

-- Auto-update updated_at on alerts
DROP TRIGGER IF EXISTS trg_alerts_updated_at ON alerts;
CREATE TRIGGER trg_alerts_updated_at
    BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- When an alert_event is inserted, update the parent alert's counters
CREATE OR REPLACE FUNCTION sync_alert_on_event()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE alerts
    SET triggered_count   = triggered_count + 1,
        last_triggered_at = NEW.triggered_at,
        updated_at        = NOW()
    WHERE id = NEW.alert_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_alert_events_sync_parent ON alert_events;
CREATE TRIGGER trg_alert_events_sync_parent
    AFTER INSERT ON alert_events
    FOR EACH ROW EXECUTE FUNCTION sync_alert_on_event();

-- Function to check a price-based alert condition (called by application layer or pg_cron)
CREATE OR REPLACE FUNCTION check_price_alerts(p_symbol_id UUID, p_current_price NUMERIC)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_alert     RECORD;
    v_condition JSONB;
    v_op        TEXT;
    v_value     NUMERIC;
    v_triggered INTEGER := 0;
    v_message   TEXT;
BEGIN
    FOR v_alert IN
        SELECT * FROM alerts
        WHERE symbol_id = p_symbol_id
          AND is_active = TRUE
          AND alert_type = 'price'
          AND deleted_at IS NULL
    LOOP
        v_condition := v_alert.condition;
        v_op        := v_condition->>'op';
        v_value     := (v_condition->>'value')::NUMERIC;

        v_message := NULL;

        CASE v_op
            WHEN 'gte' THEN IF p_current_price >= v_value THEN v_message := format('Price reached %.2f (threshold: %.2f)', p_current_price, v_value); END IF;
            WHEN 'lte' THEN IF p_current_price <= v_value THEN v_message := format('Price fell to %.2f (threshold: %.2f)', p_current_price, v_value); END IF;
            WHEN 'gt'  THEN IF p_current_price >  v_value THEN v_message := format('Price above %.2f (threshold: %.2f)', p_current_price, v_value); END IF;
            WHEN 'lt'  THEN IF p_current_price <  v_value THEN v_message := format('Price below %.2f (threshold: %.2f)', p_current_price, v_value); END IF;
            ELSE NULL;
        END CASE;

        IF v_message IS NOT NULL THEN
            INSERT INTO alert_events (alert_id, triggered_at, trigger_value, message, was_notified)
            VALUES (v_alert.id, NOW(), p_current_price, v_message, FALSE);
            v_triggered := v_triggered + 1;
        END IF;
    END LOOP;

    RETURN v_triggered;
END;
$$;

COMMENT ON FUNCTION check_price_alerts(UUID, NUMERIC) IS 'Evaluates all active price alerts for a symbol against the given price; returns count of alerts triggered';
