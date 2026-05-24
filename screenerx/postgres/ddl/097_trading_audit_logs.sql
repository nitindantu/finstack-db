-- ============================================================
-- Table: trading_audit_logs
-- Domain: Trading / Compliance
-- Added: v1.4.0 — Native Trade Execution Engine
-- ============================================================
-- Tamper-resistant, insert-only audit trail for all trading
-- actions. No updated_at column — rows are immutable by design.
-- Every order place/modify/cancel, basket execution, GTT change,
-- session connect, and RMS check result is recorded here.
-- ============================================================

CREATE TABLE IF NOT EXISTS screenerx.trading_audit_logs (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    user_id             UUID            NOT NULL,
    broker_account_id   UUID,
    action              VARCHAR(50)     NOT NULL,
    -- order_place | order_modify | order_cancel | order_fill
    -- basket_execute | gtt_create | gtt_cancel
    -- session_connect | session_disconnect
    -- rms_check_pass | rms_check_block | kill_switch_activate
    entity_type         VARCHAR(30)     NOT NULL,
    -- order | basket | basket_item | gtt | session | rms | kill_switch
    entity_id           VARCHAR(255),
    before_state        JSONB           DEFAULT '{}',
    after_state         JSONB           DEFAULT '{}',
    ip_address          INET,
    user_agent          TEXT,
    outcome             VARCHAR(20)     NOT NULL DEFAULT 'success',
    -- success | failure | blocked | partial
    rms_checks          JSONB           DEFAULT '[]',
    -- [{check: "max_daily_loss", passed: true, value: -5000, limit: -50000}]
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    -- No updated_at — rows are immutable

    CONSTRAINT trading_audit_logs_pkey PRIMARY KEY (id),
    CONSTRAINT trading_audit_logs_outcome_check CHECK (
        outcome IN ('success','failure','blocked','partial')
    )
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_time
    ON screenerx.trading_audit_logs (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity
    ON screenerx.trading_audit_logs (entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_action
    ON screenerx.trading_audit_logs (action, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_logs_broker_account
    ON screenerx.trading_audit_logs (broker_account_id, created_at DESC)
    WHERE broker_account_id IS NOT NULL;
