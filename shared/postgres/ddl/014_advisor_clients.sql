CREATE TABLE IF NOT EXISTS shared.advisor_clients (
    id                  UUID NOT NULL DEFAULT gen_random_uuid(),
    advisor_id          UUID NOT NULL,
    client_id           UUID NOT NULL,
    relationship_status VARCHAR(20) NOT NULL DEFAULT 'pending'
                            CHECK (relationship_status IN ('active','pending','paused','terminated')),
    engagement_model    VARCHAR(20) NOT NULL DEFAULT 'digital_first'
                            CHECK (engagement_model IN ('full_service','digital_first','review_only')),
    aum_managed         DECIMAL(18,2),
    fee_structure       JSONB,
    notes               TEXT,
    kyc_verified        BOOLEAN NOT NULL DEFAULT FALSE,
    sebi_ria_number     VARCHAR(50),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT advisor_clients_pk PRIMARY KEY (id),
    CONSTRAINT advisor_clients_pair_uq UNIQUE (advisor_id, client_id)
);

CREATE INDEX IF NOT EXISTS idx_advisor_clients_advisor ON shared.advisor_clients (advisor_id, relationship_status);
CREATE INDEX IF NOT EXISTS idx_advisor_clients_client ON shared.advisor_clients (client_id);
