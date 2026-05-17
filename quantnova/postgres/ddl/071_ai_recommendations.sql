-- ============================================================
-- Table: ai_recommendations
-- Domain: AI/ML
-- ============================================================

CREATE TABLE IF NOT EXISTS quantnova.ai_recommendations (
    id                      UUID                NOT NULL DEFAULT gen_random_uuid(),
    user_id                 UUID                NOT NULL,
    symbol_id               UUID                NOT NULL,
    recommendation_type     recommendation_type NOT NULL,
    reasoning               TEXT,
    confidence              NUMERIC(6,4)        NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    supporting_data         JSONB               NOT NULL DEFAULT '{}',
    expires_at              TIMESTAMPTZ,
    was_acted_on            BOOLEAN             NOT NULL DEFAULT FALSE,
    metadata                JSONB               NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ,
    created_by              UUID,
    updated_by              UUID,

    CONSTRAINT ai_recommendations_pkey PRIMARY KEY (id),
    CONSTRAINT ai_recommendations_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id) ON DELETE CASCADE,
    CONSTRAINT ai_recommendations_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id) ON DELETE CASCADE
);

COMMENT ON TABLE ai_recommendations IS 'AI-generated buy/sell/hold recommendations delivered to users';
COMMENT ON COLUMN ai_recommendations.supporting_data IS 'JSON with the data points that drove this recommendation';
COMMENT ON COLUMN ai_recommendations.was_acted_on IS 'TRUE if the user placed a trade aligned with this recommendation';
