# Release Notes

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

### v1.1.0 (planned)

- NDFL seed data population
- `screenerx.option_chains` table for F&O data
- `screenerx.global_indices` table for cross-market index tracking
- `quantnova.paper_trading_results` table for paper trading performance attribution
- Redis Streams integration for replay-capable event log

### v1.2.0 (planned)

- Row-Level Security policies documented as explicit SQL in a dedicated `rls/` directory
- `shared.tenant_configs` table for per-tenant feature flags
- Elasticsearch index lifecycle management (ILM) policies for the `news` index
- Kafka Connect configuration files for CDC from PostgreSQL to Elasticsearch
