-- ============================================================
-- Table: screener_filters
-- Domain: Screening
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.screener_filters (
    id                      UUID            NOT NULL DEFAULT gen_random_uuid(),
    screener_template_id    UUID            NOT NULL,
    field_name              VARCHAR(200)    NOT NULL,
    operator                filter_operator NOT NULL,
    value_min               NUMERIC(20,6),
    value_max               NUMERIC(20,6),
    value_text              TEXT,
    value_list              TEXT[],
    metadata                JSONB           NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT screener_filters_pkey PRIMARY KEY (id),
    CONSTRAINT screener_filters_template_fk FOREIGN KEY (screener_template_id) REFERENCES screenerx.screener_templates (id) ON DELETE CASCADE,
    CONSTRAINT screener_filters_range_check CHECK (value_max IS NULL OR value_min IS NULL OR value_max >= value_min)
);

COMMENT ON TABLE screener_filters IS 'Individual filter criteria belonging to a screener template';
COMMENT ON COLUMN screener_filters.field_name IS 'Dot-notation field path, e.g. financial_ratios.pe_ratio';
COMMENT ON COLUMN screener_filters.operator IS 'Comparison operator';
COMMENT ON COLUMN screener_filters.value_min IS 'Lower bound for between/gte operators';
COMMENT ON COLUMN screener_filters.value_max IS 'Upper bound for between/lte operators';
COMMENT ON COLUMN screener_filters.value_list IS 'Array for IN / NOT IN operators';
