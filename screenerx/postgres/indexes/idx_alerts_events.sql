-- ============================================================
-- Indexes: alerts, alert_events, event_store, notifications
-- ============================================================

-- alerts
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alerts_user_id
    ON alerts (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alerts_symbol_id
    ON alerts (symbol_id)
    WHERE symbol_id IS NOT NULL AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alerts_active
    ON alerts (user_id, alert_type)
    WHERE is_active = TRUE AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alerts_condition
    ON alerts USING gin (condition);

-- alert_events
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alert_events_alert_id
    ON alert_events (alert_id, triggered_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_alert_events_unnotified
    ON alert_events (triggered_at DESC)
    WHERE was_notified = FALSE;

-- event_store
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_store_aggregate
    ON event_store (aggregate_type, aggregate_id, occurred_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_store_event_type
    ON event_store (event_type, occurred_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_store_occurred_at
    ON event_store (occurred_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_event_store_data
    ON event_store USING gin (event_data);

-- notifications
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_user_id
    ON notifications (user_id, created_at DESC)
    WHERE deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_unread
    ON notifications (user_id, created_at DESC)
    WHERE read_at IS NULL AND deleted_at IS NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_notifications_channel
    ON notifications (channel, created_at DESC);

-- websocket_sessions
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_websocket_sessions_user_id
    ON websocket_sessions (user_id, connected_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_websocket_sessions_active
    ON websocket_sessions (user_id)
    WHERE disconnected_at IS NULL;

-- user_activity
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_activity_user_id
    ON user_activity (user_id, created_at DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_activity_action_type
    ON user_activity (action_type, created_at DESC);

-- search_logs
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_search_logs_user_id
    ON search_logs (user_id, created_at DESC)
    WHERE user_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_search_logs_query_trgm
    ON search_logs USING gin (query gin_trgm_ops);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_search_logs_created_at
    ON search_logs (created_at DESC);

-- kpi_metrics
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_kpi_metrics_entity_metric
    ON kpi_metrics (entity_type, entity_id, metric_name, metric_date DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_kpi_metrics_metric_date
    ON kpi_metrics (metric_name, metric_date DESC);
