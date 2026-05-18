CREATE TABLE IF NOT EXISTS screenerx.ai_copilot_sessions (
    id              UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL,
    title           VARCHAR(255) NOT NULL DEFAULT 'New Conversation',
    session_type    VARCHAR(30) NOT NULL DEFAULT 'general'
                        CHECK (session_type IN ('general','portfolio','tax','planning','advisor','retirement')),
    context_snapshot JSONB NOT NULL DEFAULT '{}',
    status          VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','archived')),
    message_count   INTEGER NOT NULL DEFAULT 0,
    total_tokens_used INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ai_copilot_sessions_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ai_copilot_sessions_user ON screenerx.ai_copilot_sessions (user_id, status, updated_at DESC);
