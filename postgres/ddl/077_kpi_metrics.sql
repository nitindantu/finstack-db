-- ============================================================
-- Table: kpi_metrics
-- Domain: Analytics (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS kpi_metrics (
    entity_type     VARCHAR(100)    NOT NULL,
    entity_id       UUID            NOT NULL,
    metric_name     VARCHAR(200)    NOT NULL,
    metric_value    NUMERIC(20,6)   NOT NULL,
    metric_date     DATE            NOT NULL,
    metadata        JSONB           NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT kpi_metrics_pkey PRIMARY KEY (entity_type, entity_id, metric_name, metric_date)
);

COMMENT ON TABLE kpi_metrics IS 'General-purpose KPI time series for platform analytics; hypertable on metric_date';
COMMENT ON COLUMN kpi_metrics.entity_type IS 'Type of entity being measured, e.g. user, portfolio, strategy, exchange';
COMMENT ON COLUMN kpi_metrics.entity_id IS 'UUID of the specific entity instance';
COMMENT ON COLUMN kpi_metrics.metric_name IS 'Metric identifier, e.g. dau, trades_count, screener_runs, revenue_inr';
