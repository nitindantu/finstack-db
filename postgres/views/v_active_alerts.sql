-- ============================================================
-- View: v_active_alerts
-- Active alerts with symbol and last trigger info
-- ============================================================

CREATE OR REPLACE VIEW v_active_alerts AS
SELECT
    a.id                            AS alert_id,
    a.user_id,
    u.email                         AS user_email,
    u.full_name                     AS user_name,
    s.id                            AS symbol_id,
    s.ticker,
    s.name                          AS symbol_name,
    e.code                          AS exchange_code,
    a.alert_type,
    a.condition,
    a.notification_channels,
    a.triggered_count,
    a.last_triggered_at,
    a.created_at,
    -- Current price from latest tick
    dp.close                        AS current_price,
    dp.date                         AS price_as_of,
    -- Last event
    ae.triggered_at                 AS last_event_at,
    ae.trigger_value                AS last_trigger_value,
    ae.message                      AS last_message,
    ae.was_notified                 AS last_was_notified
FROM alerts a
JOIN users u ON u.id = a.user_id AND u.deleted_at IS NULL
LEFT JOIN symbols s ON s.id = a.symbol_id
LEFT JOIN exchanges e ON e.id = s.exchange_id
LEFT JOIN LATERAL (
    SELECT close, date FROM market_data_1d d WHERE d.symbol_id = a.symbol_id ORDER BY d.date DESC LIMIT 1
) dp ON a.symbol_id IS NOT NULL
LEFT JOIN LATERAL (
    SELECT triggered_at, trigger_value, message, was_notified
    FROM alert_events ae2 WHERE ae2.alert_id = a.id ORDER BY ae2.triggered_at DESC LIMIT 1
) ae ON TRUE
WHERE a.is_active = TRUE AND a.deleted_at IS NULL;

COMMENT ON VIEW v_active_alerts IS 'All active alerts with current price context and last trigger event';
