CREATE TABLE IF NOT EXISTS screenerx.market_intelligence_summaries (
    id           UUID NOT NULL DEFAULT gen_random_uuid(),
    summary_type VARCHAR(30) NOT NULL
                     CHECK (summary_type IN ('daily_market','sector','stock','macro','earnings','fii_dii')),
    reference_id VARCHAR(255),
    title        VARCHAR(500) NOT NULL,
    content      TEXT NOT NULL,
    key_insights JSONB NOT NULL DEFAULT '[]',
    sentiment    VARCHAR(10) NOT NULL DEFAULT 'neutral'
                     CHECK (sentiment IN ('bullish','bearish','neutral','mixed')),
    confidence   DECIMAL(3,2),
    sources      JSONB NOT NULL DEFAULT '[]',
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    valid_until  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT market_intelligence_summaries_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_market_intel_type ON screenerx.market_intelligence_summaries (summary_type, is_published, valid_until DESC);
CREATE INDEX IF NOT EXISTS idx_market_intel_ref ON screenerx.market_intelligence_summaries (reference_id, summary_type);
