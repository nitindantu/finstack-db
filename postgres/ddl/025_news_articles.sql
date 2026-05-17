-- ============================================================
-- Table: news_articles
-- Domain: Market Data
-- ============================================================

CREATE TABLE IF NOT EXISTS news_articles (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid(),
    headline            VARCHAR(1000)   NOT NULL,
    summary             TEXT,
    content             TEXT,
    source              VARCHAR(255)    NOT NULL,
    author              VARCHAR(255),
    url                 TEXT,
    published_at        TIMESTAMPTZ     NOT NULL,
    symbols             TEXT[]          NOT NULL DEFAULT '{}',
    sectors             TEXT[]          NOT NULL DEFAULT '{}',
    sentiment_score     NUMERIC(5,4)    CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1)),
    sentiment_label     sentiment_label,
    relevance_score     NUMERIC(5,4)    CHECK (relevance_score IS NULL OR (relevance_score >= 0 AND relevance_score <= 1)),
    metadata            JSONB           NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT news_articles_pkey PRIMARY KEY (id),
    CONSTRAINT news_articles_url_unique UNIQUE (url)
);

COMMENT ON TABLE news_articles IS 'Financial news articles with NLP-derived sentiment and relevance scores';
COMMENT ON COLUMN news_articles.symbols IS 'Array of ticker symbols mentioned or relevant to this article';
COMMENT ON COLUMN news_articles.sentiment_score IS 'Float in [-1, 1]; negative = bearish, positive = bullish';
COMMENT ON COLUMN news_articles.relevance_score IS 'Float in [0, 1] measuring how relevant the article is to the tagged symbols';
