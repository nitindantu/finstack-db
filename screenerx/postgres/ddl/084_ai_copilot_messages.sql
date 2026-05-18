CREATE TABLE IF NOT EXISTS screenerx.ai_copilot_messages (
    id              UUID NOT NULL DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES screenerx.ai_copilot_sessions(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('user','assistant','system')),
    content         TEXT NOT NULL,
    thinking        TEXT,
    tool_calls      JSONB,
    tool_results    JSONB,
    context_used    JSONB,
    confidence_score DECIMAL(3,2),
    latency_ms      INTEGER,
    input_tokens    INTEGER,
    output_tokens   INTEGER,
    model_id        VARCHAR(100),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ai_copilot_messages_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ai_copilot_messages_session ON screenerx.ai_copilot_messages (session_id, created_at ASC);
