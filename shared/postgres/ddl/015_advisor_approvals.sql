CREATE TABLE IF NOT EXISTS shared.advisor_approvals (
    id                  UUID NOT NULL DEFAULT gen_random_uuid(),
    advisor_id          UUID NOT NULL,
    client_id           UUID NOT NULL,
    approval_type       VARCHAR(30) NOT NULL
                            CHECK (approval_type IN ('recommendation','tax_plan','rebalancing','goal_change')),
    reference_id        UUID,
    ai_suggestion       JSONB NOT NULL DEFAULT '{}',
    advisor_action      VARCHAR(20) NOT NULL DEFAULT 'pending'
                            CHECK (advisor_action IN ('pending','approved','modified','rejected')),
    advisor_notes       TEXT,
    modified_suggestion JSONB,
    acted_at            TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT advisor_approvals_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_advisor_approvals_advisor ON shared.advisor_approvals (advisor_id, advisor_action);
CREATE INDEX IF NOT EXISTS idx_advisor_approvals_client ON shared.advisor_approvals (client_id);
