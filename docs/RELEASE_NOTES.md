# Release Notes

---

## v1.3.0 — 2026-05-18

### Overview

AI financial platform tables — 9 new screenerx tables (083–091) and 2 shared tables (014–015) supporting the ScreenerX AI modules.

### New Tables — screenerx schema

| Migration | Table | Purpose |
|-----------|-------|---------|
| `083_ai_copilot_sessions.sql` | `screenerx.ai_copilot_sessions` | AI chat session tracking |
| `084_ai_copilot_messages.sql` | `screenerx.ai_copilot_messages` | Message history with token tracking |
| `085_risk_profiles.sql` | `screenerx.risk_profiles` | SEBI risk-o-meter user profiles |
| `086_financial_goals.sql` | `screenerx.financial_goals` | Goal tracking with Monte Carlo results |
| `087_retirement_plans.sql` | `screenerx.retirement_plans` | Retirement corpus planning |
| `088_portfolio_analyses.sql` | `screenerx.portfolio_analyses` | Sharpe/Sortino ratio analytics |
| `089_ai_investment_recommendations.sql` | `screenerx.ai_investment_recommendations` | Personalized AI recommendations |
| `090_market_intelligence_summaries.sql` | `screenerx.market_intelligence_summaries` | Cached AI market summaries |
| `091_financial_health_scores.sql` | `screenerx.financial_health_scores` | Composite financial health scores |

### New Tables — shared schema

| Migration | Table | Purpose |
|-----------|-------|---------|
| `014_advisor_clients.sql` | `shared.advisor_clients` | Advisor-client relationships |
| `015_advisor_approvals.sql` | `shared.advisor_approvals` | Human-in-loop approval workflow |

---

## v1.2.0 — 2026-05-17

### Overview

Institution-grade GitHub Actions CI/CD pipeline — automated SQL validation, Neon branch dry-runs on every PR, auto-migration to staging on main push, manual-approval production migration on semver tags, semantic versioning, and contributing conventions.

---

### New GitHub Actions Workflows

| File | Trigger | What it does |
|------|---------|-------------|
| `validate.yml` | PR to main/develop | SQL lint (sqlfluff), naming convention check (NNN_*.sql, seed_NNN_*.sql), destructive statement detector, Neon branch dry-run (spins ephemeral branch, runs all migrations, verifies table counts, deletes branch), posts schema diff as PR comment |
| `migrate-staging.yml` | Push to main (*.sql changed) | Applies all domain migrations + seed data to Neon staging branch; path-filtered so it only fires when SQL files change |
| `migrate-production.yml` | Push of v*.*.* tag | Applies migrations to Neon production with GitHub Environment manual-approval gate; pre-flight connection check; tags schema with release version; opens urgent GitHub Issue on failure |
| `release.yml` | Push to main | semantic-release: reads conventional commits, bumps semver, writes CHANGELOG.md, creates GitHub Release + tag |

---

### New Repository Files

| File | Purpose |
|------|---------|
| `.github/CODEOWNERS` | Per-schema team ownership; `.github/` locked to core-team; schema dirs owned by respective teams |
| `.github/dependabot.yml` | Weekly GitHub Actions dependency updates |
| `.github/pull_request_template.md` | SQL-specific PR checklist: additive-only rule, naming conventions, Prisma sync reminder, docs update confirmation, rollback plan |
| `.releaserc.json` | semantic-release config: changelog → git commit → GitHub Release |
| `CONTRIBUTING.md` | Conventional commits guide, migration rules, naming conventions, schema dependency order, branch strategy |

---

### Conventions Enforced by CI

**Commit format (drives semantic-release version bumps):**
- `feat(scope):` → minor bump (new table/column/index/seed)
- `fix(scope):` → patch bump (DDL bug fix)
- `docs(scope):` → no bump
- `BREAKING CHANGE:` footer → major bump

**Scopes:** shared, screenerx, quantnova, ndfl, timescaledb, redis, kafka, elasticsearch, docs, ci, seed

**Migration safety rules checked automatically:**
- DDL files must match `NNN_name.sql`
- Seed files must match `seed_NNN_name.sql`
- `DROP TABLE`, `DROP COLUMN`, `TRUNCATE` trigger a warning in CI

---

### Required GitHub Secrets

| Secret | Used by |
|--------|---------|
| `STAGING_DATABASE_URL` | migrate-staging, validate dry-run |
| `PRODUCTION_DATABASE_URL` | migrate-production |
| `NEON_API_KEY` | validate Neon branch dry-run |
| `NEON_PROJECT_ID` | validate Neon branch dry-run |
| `STAGING_DB_PASSWORD` | validate Neon branch dry-run |

---

### Breaking Changes

None.

---

## v1.1.0 — 2026-05-17

### Overview

Dashboard data layer — four new tables and seed data powering the ScreenerX live dashboard. All previously hardcoded dashboard values (indices, FII/DII, IPOs, economic calendar) now read from the database.

---

### New Tables

#### `screenerx.market_indices`

Stores daily snapshots of domestic and global market indices, including a sparkline JSON array for mini-charts.

| Column | Type | Notes |
|--------|------|-------|
| `symbol` | VARCHAR(50) | Index ticker (NIFTY, SENSEX, SPX, etc.) |
| `name` | VARCHAR(200) | Display name |
| `region` | VARCHAR(100) | India / USA / UK / Japan etc. |
| `index_type` | VARCHAR(20) | `domestic` / `global` / `sector` / `vix` |
| `current_value` | DECIMAL(18,2) | Latest index level |
| `change_value` | DECIMAL(18,2) | Absolute change from previous close |
| `change_pct` | DECIMAL(8,4) | Percentage change |
| `sparkline` | JSONB | Array of ~12 intraday/recent values for mini-chart |
| `trade_date` | DATE | Date of snapshot (unique per symbol+date) |

**Seeded with:** 15 indices — NIFTY 50, SENSEX, NIFTY BANK, NIFTY IT, NIFTY MIDCAP 100, INDIA VIX, S&P 500, NASDAQ 100, DOW JONES, FTSE 100, DAX, NIKKEI 225, HANG SENG, SSE Composite, NIFTY SMALLCAP 100.

---

#### `screenerx.fii_dii_activity`

Daily FII (Foreign Institutional Investor) and DII (Domestic Institutional Investor) equity buy/sell figures in crore INR. `fii_net` and `dii_net` are generated columns (buy − sell).

| Column | Type | Notes |
|--------|------|-------|
| `activity_date` | DATE | Trading date (unique per date+segment) |
| `fii_buy` | DECIMAL(18,2) | FII gross purchases (₹ Cr) |
| `fii_sell` | DECIMAL(18,2) | FII gross sales (₹ Cr) |
| `fii_net` | DECIMAL(18,2) | Generated: fii_buy − fii_sell |
| `dii_buy` | DECIMAL(18,2) | DII gross purchases (₹ Cr) |
| `dii_sell` | DECIMAL(18,2) | DII gross sales (₹ Cr) |
| `dii_net` | DECIMAL(18,2) | Generated: dii_buy − dii_sell |
| `segment` | VARCHAR(20) | `equity` / `debt` / `hybrid` |

**Seeded with:** 10 days of equity segment data.

---

#### `screenerx.ipos`

IPO tracker covering upcoming, open, closed, and recently listed IPOs with GMP (Grey Market Premium) and subscription details.

| Column | Type | Notes |
|--------|------|-------|
| `company_name` | VARCHAR(500) | Issuer name |
| `ticker` | VARCHAR(50) | Post-listing NSE/BSE symbol |
| `issue_size_cr` | DECIMAL(18,2) | Total issue size in crore INR |
| `price_band_low/high` | DECIMAL(10,2) | Price band range |
| `lot_size` | INTEGER | Minimum application lot |
| `open_date` / `close_date` | DATE | Subscription window |
| `listing_date` | DATE | Exchange listing date |
| `listing_price` | DECIMAL(10,2) | Actual listing price (post-listing) |
| `gmp` | DECIMAL(10,2) | Grey Market Premium in ₹ |
| `status` | VARCHAR(20) | `upcoming` / `open` / `closed` / `listed` / `withdrawn` |
| `subscription_times` | DECIMAL(8,2) | Overall subscription multiple |

**Seeded with:** 7 IPOs — Bajaj Housing Finance (open), Ola Electric, FirstCry, Emcure, Niva Bupa (upcoming), Hyundai Motor India, Swiggy (listed).

---

#### `screenerx.economic_events` (existing table — new seed data)

Previously defined in v1.0.0 DDL but not seeded. Now populated with upcoming macro events.

**Seeded with:** 10 events — India CPI, US FOMC Minutes, India WPI, US Retail Sales, ECB Rate Decision, India GDP, US NFP, RBI Policy, US CPI, India IIP.

---

### New API Endpoints (ScreenerX Backend)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/market/indices` | Index cards with sparklines (`?type=domestic\|global\|sector\|vix`) |
| GET | `/api/v1/market/fii-dii` | FII/DII activity + 5-day net summary (`?days=10`) |
| GET | `/api/v1/market/ipos` | IPO tracker (`?status=upcoming\|open\|listed`) |
| GET | `/api/v1/market/events` | Economic calendar (`?days=30`) |
| GET | `/api/v1/market/breadth` | Advance/decline/unchanged from `market_data_1d` |

---

### New Migration Files

| File | Purpose |
|------|---------|
| `screenerx/postgres/ddl/080_market_indices.sql` | market_indices DDL + indexes |
| `screenerx/postgres/ddl/081_fii_dii_activity.sql` | fii_dii_activity DDL + indexes |
| `screenerx/postgres/ddl/082_ipos.sql` | ipos DDL + indexes |
| `screenerx/postgres/dml/seed_010_market_indices.sql` | 15 index snapshots |
| `screenerx/postgres/dml/seed_011_fii_dii.sql` | 10 days FII/DII data |
| `screenerx/postgres/dml/seed_012_ipos.sql` | 7 IPOs |
| `screenerx/postgres/dml/seed_013_economic_events.sql` | 10 economic events |

---

### Updated Database Object Counts

| Category | v1.0.0 | v1.1.0 | Delta |
|---|---|---|---|
| Tables | 91 | 94 | +3 |
| Seeded economic events | 0 | 10 | +10 |
| Seeded IPOs | 0 | 7 | +7 |
| Seeded market indices | 0 | 15 | +15 |
| Seeded FII/DII records | 0 | 10 | +10 |

---

### Breaking Changes

None.

---

## v1.0.0 — 2026-05-17 (Initial Release)

### Overview

First production release of **finstack-db** — enterprise polyglot database architecture for the Finstack platform suite. This release establishes the complete schema foundation across four project domains (shared, screenerx, quantnova, ndfl), shipping 91 tables, 35 enum types, full TimescaleDB time-series configuration, Redis key schemas, Elasticsearch mappings, and Kafka event schemas.

---

### What's Included

#### Schemas

**`shared` (13 tables)** — Cross-project identity, authentication, authorisation, billing, and notification infrastructure. Provides the `shared.users` table referenced by all other domains, a complete RBAC system (roles, permissions, user_roles, role_permissions), Stripe-backed subscription and billing management, JWT sessions with refresh token rotation, API key authentication, OAuth provider links, device push token registry, user preference storage, and an append-only audit log.

**`screenerx` (47 tables)** — Stock screener and portfolio management platform. Covers exchange and instrument master data, multi-timeframe market data (tick through daily OHLCV), Level-2 order book snapshots, corporate actions (dividends, splits, bonuses, mergers), quarterly financial statements (balance sheet, P&L, cash flow), pre-computed financial ratios, shareholding patterns, analyst ratings, a complete screener engine (templates, filters, saved screeners, execution cache), portfolio management (positions, transactions, EOD snapshots, performance attribution), watchlists, financial goals, rebalancing rules, price/volume/fundamental/news alerts with trigger log, WebSocket session management, and platform analytics.

**`quantnova` (23 tables)** — Quantitative trading and AI/ML research platform. Covers broker integration and multi-account management, full order lifecycle (placement through fills and execution confirmation), real-time positions and P&L snapshots, risk limit enforcement, algorithmic strategy versioning, backtesting infrastructure with result storage, parameter optimisation, alpha signal generation, ML model registry with versioned artifacts, a feature store with historical values, training run management, inference audit logging, AI investment recommendations, and model drift detection. Uses the event sourcing pattern via an immutable event_store hypertable.

**`ndfl` (8 tables)** — Indian income tax return and compliance workflow. Covers tax year tracking with ITR form selection and filing status, multi-head income recording, individual capital gains transactions (STCG/LTCG) with indexed cost support, TDS record management from Form 16/16A, Form 26AS import and parsing, full tax computation with all Chapter VI-A deductions, advance tax and self-assessment challan records, and supporting document upload management.

---

#### Infrastructure

**PostgreSQL extensions (installed at bootstrap):**
- `uuid-ossp` — UUID generation functions
- `pgcrypto` — `gen_random_uuid()`, `encrypt()` / `decrypt()` for sensitive columns
- `pg_trgm` — Trigram similarity indexes for fuzzy text search
- `btree_gin` — GIN indexes on composite key types

**TimescaleDB hypertable configuration (18 tables):**
- `market_data_ticks` — 1-day chunks, 16 space partitions on symbol_id
- `order_books` — 1-day chunks, 8 space partitions on symbol_id
- `market_data_1m` — 7-day chunks
- `market_data_5m` — 14-day chunks
- `market_data_15m` — 30-day chunks
- `market_data_1h` — 90-day chunks
- `market_data_1d` — 1-year chunks (DATE column)
- `sentiment_data` — 7-day chunks
- `financial_ratios` — 3-month chunks
- `portfolio_snapshots` — 3-month chunks
- `portfolio_performance` — 3-month chunks
- `alert_events` — 14-day chunks
- `kpi_metrics` — 1-month chunks
- `user_activity` — 7-day chunks
- `pnl_snapshots` — 1-day chunks
- `alpha_signals` — 1-month chunks
- `feature_values` — 3-month chunks
- `inference_logs` — 7-day chunks
- `event_store` — 7-day chunks

**TimescaleDB continuous aggregates:**
- `cagg_market_data_5m` — 5-minute OHLCV from ticks, 5-minute refresh, 10-minute lag
- `cagg_market_data_1h` — 1-hour OHLCV from 5m aggregate, 1-hour refresh
- `cagg_daily_volume_profile` — Daily VWAP and volume profile, once per market close

**TimescaleDB policies:**
- Compression: chunks older than 7 days (ticks), 30 days (OHLCV) compressed with lz4
- Retention: tick data 90 days, 1m OHLCV 2 years, inference logs 1 year, user activity 1 year

**Redis key schema documentation:**
- `screenerx/redis/key_schemas.md` — Market price hashes, order book sorted sets, OHLCV bar caches, market status, screener result cache, execution locks, watchlist sorted sets, portfolio NAV and positions, alert cooldowns, market rankings, pub/sub channels
- `quantnova/redis/key_schemas.md` — Order state hashes, position cache, daily loss tracking
- `shared/redis/key_schemas.md` — Session hashes, rate-limit counters, OTP tokens, API key cache

**Elasticsearch index mappings:**
- `stocks_mapping.json` — Instrument search with ticker_analyzer, name_analyzer, edge_ngram_analyzer, sector/industry facets
- `news_mapping.json` — News full-text search with symbol tagging, sentiment filtering, date-range queries

**Kafka event schemas (JSON Schema draft-07, Confluent Schema Registry compatible):**
- `market_tick_event.json` — Real-time tick data from exchange feeds
- `order_event.json` — Order lifecycle state transitions
- `execution_event.json` — Confirmed broker execution records
- `signal_event.json` — Strategy-generated trading signals
- `risk_event.json` — Risk limit breach notifications
- `alert_triggered_event.json` — User alert trigger events
- `portfolio_updated_event.json` — Portfolio change events
- `tax_event.json` — Tax computation and filing updates
- `filing_event.json` — ITR filing status changes
- `user_event.json` — User account lifecycle events
- `notification_event.json` — Notification delivery events

---

#### Database Objects

| Category | Count |
|---|---|
| Tables | 91 |
| PostgreSQL schemas | 4 (shared, screenerx, quantnova, ndfl) |
| Enum types | 35 |
| Stored functions | 4 |
| Trigger sets | 4 |
| Views | 3 |
| Materialized views | 4 |
| RLS policies | Active on all user-owned tables |
| Index files | 13 |
| TimescaleDB hypertables | 18 |
| Continuous aggregates | 3 |
| Kafka event schemas | 11 |
| Elasticsearch index mappings | 2 |

**Views:**
- `screenerx.v_stock_overview` — Symbol + latest price + company headline metrics
- `screenerx.v_portfolio_holdings` — Portfolio positions with current valuations
- `screenerx.v_active_alerts` — Active alerts with last trigger context

**Materialized views:**
- `screenerx.mv_stock_daily_summary` — Daily OHLCV + fundamentals per symbol
- `screenerx.mv_sector_performance` — Sector-level aggregate performance
- `screenerx.mv_portfolio_summary` — Per-user portfolio summary across all portfolios
- `screenerx.mv_top_movers` — Top 20 gainers, losers, and volume leaders per exchange

**Stored functions:**
- `shared.audit_trigger_function()` — Generic trigger function for all audit log writes
- `shared.soft_delete_function()` — Sets deleted_at and cascades to child tables where appropriate
- `screenerx.portfolio_value_function()` — Computes portfolio NAV given a portfolio_id and optional date
- `screenerx.screener_execute_function()` — Evaluates a JSON filter set against the instrument universe

**Triggers:**
- `shared.users_trigger` — Auto-maintains updated_at; fires audit log on all mutations
- `screenerx.alert_trigger` — Evaluates alert conditions after market_data_ohlcv inserts
- `screenerx.portfolio_trigger` — Recalculates portfolio_positions and unrealised_pnl on transaction insert
- `quantnova.orders_trigger` — Validates risk limits before order INSERT; updates pnl_snapshots after execution

---

#### Seed Data

| Entity | Count | Notes |
|---|---|---|
| Users | 15 | Spread across admin, analyst, trader, viewer roles; multiple tenants |
| Exchanges | 8 | NSE, BSE, NYSE, NASDAQ, MCX, LSE, SGX, NCDEX |
| Symbols | 20 | 10 NSE/BSE Indian stocks, 5 NASDAQ US stocks, 5 NSE indices |
| Companies | 8 | Full corporate profiles with financials summary |
| OHLCV records (daily) | 975 | ~50 trading days × 20 symbols on market_data_ohlcv (1d) |
| Portfolios | 5 | Mix of real and paper portfolios with active positions |
| Watchlists | 4 | Pre-populated with symbols |
| Screener templates | Sample set | Value, momentum, and growth screeners |
| Brokers | 5 | Zerodha, Upstox, Angel Broking, HDFC Securities, ICICI Direct |
| Trading strategies | 3 | Momentum, mean-reversion, and ML-based strategy samples |

---

### Known Limitations

1. **TimescaleDB continuous aggregates require self-hosted PostgreSQL with the TimescaleDB extension installed.** Neon (cloud PostgreSQL) and plain PostgreSQL 16 instances will create all tables normally, but the `create_hypertable()` and `add_continuous_aggregate_policy()` calls in the TimescaleDB files will fail. Skip or comment out `screenerx/timescaledb/` scripts on Neon.

2. **Neon compatibility:** All 91 core tables, all enum types, all views, materialized views, functions, and triggers are fully compatible with Neon PostgreSQL. Only TimescaleDB-specific hypertable configuration is unavailable.

3. **ndfl seed data not yet populated.** The `ndfl/postgres/dml/` directory exists but contains no seed scripts in this release. ndfl schema tables are fully created by the migration; they are simply empty.

4. **TimescaleDB continuous aggregates are schema-aware.** The `cagg_market_data_5m` and `cagg_market_data_1h` aggregates reference `screenerx.market_data_ticks` and must be created after the timescaledb hypertable scripts, not during the main migration.

5. **Kafka schema registry compatibility mode** is set to `BACKWARD` — future schema changes must maintain backward compatibility (new optional fields only; no field removal or type changes without a version bump).

6. **Redis key schemas are documentation only** in this release — they describe the key patterns used by application services but are not enforced by a Redis module or schema registry.

---

### Migration Guide

See [`docs/MIGRATION_GUIDE.md`](MIGRATION_GUIDE.md) for full step-by-step instructions.

**Quick path for a fresh local database:**

```bash
cd /path/to/database
docker compose -f infra/docker-compose.yml up -d
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"
./infra/scripts/init_all.sh
```

**Quick path for Neon:**

```bash
export DATABASE_URL="postgresql://<user>:<password>@<host>.neon.tech/finstack?sslmode=require"
# Run shared, screenerx, quantnova, ndfl migrations only (skip timescaledb/ files)
psql "$DATABASE_URL" -f shared/postgres/migrations/001_create_schema.sql
psql "$DATABASE_URL" -f screenerx/postgres/migrations/001_create_schema.sql
psql "$DATABASE_URL" -f quantnova/postgres/migrations/001_create_schema.sql
psql "$DATABASE_URL" -f ndfl/postgres/migrations/001_create_schema.sql
```

---

### Breaking Changes

None — this is the initial release.

---

## Upcoming / Roadmap

### v1.4.0 (planned)

- Row-Level Security policies documented as explicit SQL in a dedicated `rls/` directory
- `shared.tenant_configs` table for per-tenant feature flags
- Elasticsearch index lifecycle management (ILM) policies for the `news` index
- Kafka Connect configuration files for CDC from PostgreSQL to Elasticsearch
- Real-time FII/DII feed integration (NSE bulk data API)
