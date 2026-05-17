-- ============================================================
-- Table: corporate_actions
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.corporate_actions (
    id              UUID                    NOT NULL DEFAULT gen_random_uuid(),
    symbol_id       UUID                    NOT NULL,
    action_type     corporate_action_type   NOT NULL,
    ex_date         DATE                    NOT NULL,
    record_date     DATE,
    payment_date    DATE,
    ratio           NUMERIC(10,6),
    amount          NUMERIC(18,6),
    currency        CHAR(3)                 NOT NULL DEFAULT 'INR',
    description     TEXT,
    metadata        JSONB                   NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT corporate_actions_pkey PRIMARY KEY (id),
    CONSTRAINT corporate_actions_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT corporate_actions_record_after_ex CHECK (record_date IS NULL OR record_date >= ex_date),
    CONSTRAINT corporate_actions_payment_after_record CHECK (payment_date IS NULL OR record_date IS NULL OR payment_date >= record_date),
    CONSTRAINT corporate_actions_currency_format CHECK (currency ~ '^[A-Z]{3}$')
);

COMMENT ON TABLE corporate_actions IS 'All corporate events that affect share price or capital structure';
COMMENT ON COLUMN corporate_actions.ex_date IS 'Ex-date: shares bought on or after this date are not eligible';
COMMENT ON COLUMN corporate_actions.record_date IS 'Date on which shareholders are identified for the action';
COMMENT ON COLUMN corporate_actions.ratio IS 'Applicable for splits, bonus (e.g. 2.0 means 2:1 bonus)';
COMMENT ON COLUMN corporate_actions.amount IS 'Cash amount for dividends or buybacks per share';
