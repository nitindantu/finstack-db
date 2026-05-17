-- ============================================================
-- Table: splits
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS splits (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    symbol_id           UUID        NOT NULL,
    ex_date             DATE        NOT NULL,
    split_ratio_from    INTEGER     NOT NULL CHECK (split_ratio_from > 0),
    split_ratio_to      INTEGER     NOT NULL CHECK (split_ratio_to > 0),
    metadata            JSONB       NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT splits_pkey PRIMARY KEY (id),
    CONSTRAINT splits_symbol_fk FOREIGN KEY (symbol_id) REFERENCES symbols (id) ON DELETE CASCADE,
    CONSTRAINT splits_ratio_not_equal CHECK (split_ratio_from <> split_ratio_to)
);

COMMENT ON TABLE splits IS 'Stock split and reverse split history';
COMMENT ON COLUMN splits.split_ratio_from IS 'Number of old shares (e.g. 1 in 1:5 split)';
COMMENT ON COLUMN splits.split_ratio_to IS 'Number of new shares (e.g. 5 in 1:5 split)';
