-- ============================================================
-- Table: alpha_signals
-- Domain: Strategy & Backtest (TimescaleDB hypertable)
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.alpha_signals (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    symbol_id           UUID            NOT NULL,
    strategy_id         UUID            NOT NULL,
    signal_type         signal_type     NOT NULL,
    signal_strength     NUMERIC(6,4)    NOT NULL CHECK (signal_strength >= -1 AND signal_strength <= 1),
    signal_date         DATE            NOT NULL,
    expiry_date         DATE,
    entry_price         NUMERIC(18,6)   CHECK (entry_price IS NULL OR entry_price > 0),
    target_price        NUMERIC(18,6)   CHECK (target_price IS NULL OR target_price > 0),
    stop_loss           NUMERIC(18,6)   CHECK (stop_loss IS NULL OR stop_loss > 0),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT alpha_signals_pkey PRIMARY KEY (id, signal_date),
    CONSTRAINT alpha_signals_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE,
    CONSTRAINT alpha_signals_strategy_fk FOREIGN KEY (strategy_id) REFERENCES quantnova.strategies (id) ON DELETE CASCADE,
    CONSTRAINT alpha_signals_expiry_after_date CHECK (expiry_date IS NULL OR expiry_date >= signal_date)
);

COMMENT ON TABLE alpha_signals IS 'Generated buy/sell/exit signals from quantitative strategies; hypertable on signal_date';
COMMENT ON COLUMN alpha_signals.signal_strength IS 'Normalised signal magnitude from -1 (strong short) to +1 (strong long)';
