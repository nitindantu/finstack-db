# finstack-db

> **Enterprise-grade polyglot database architecture for fintech platforms**

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![TimescaleDB](https://img.shields.io/badge/TimescaleDB-latest-orange?logo=timescale&logoColor=white)](https://www.timescale.com/)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)](https://redis.io/)
[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-8.13-005571?logo=elasticsearch&logoColor=white)](https://www.elastic.co/)
[![Kafka](https://img.shields.io/badge/Apache_Kafka-3.6-231F20?logo=apachekafka&logoColor=white)](https://kafka.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Validate SQL](https://github.com/nitindantu/finstack-db/actions/workflows/validate.yml/badge.svg)](https://github.com/nitindantu/finstack-db/actions/workflows/validate.yml)
[![Migrate Staging](https://github.com/nitindantu/finstack-db/actions/workflows/migrate-staging.yml/badge.svg)](https://github.com/nitindantu/finstack-db/actions/workflows/migrate-staging.yml)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Domains](#project-domains)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [Schema Descriptions](#schema-descriptions)
- [Connecting to the Database](#connecting-to-the-database)
- [Environment Variables](#environment-variables)
- [CI/CD Pipeline](#cicd-pipeline)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**finstack-db** is the single source of truth for all database schemas, migrations, seed data, and infrastructure configuration powering the **Finstack** suite of financial applications.

### What this repository is

This repo contains:

- **PostgreSQL DDL** — every `CREATE TABLE`, enum type, constraint, index, trigger, function, view, and materialized view across four project domains.
- **DML seed data** — deterministic seed scripts for development and staging environments (15 users, 8 exchanges, 20 symbols, 975 OHLCV records, and more).
- **TimescaleDB configuration** — hypertable declarations, compression policies, retention policies, and continuous aggregates for 18 time-series tables.
- **Redis key schemas** — documented key patterns, types, and TTLs for all caching layers.
- **Elasticsearch index mappings** — production-ready mappings for stock and news full-text search.
- **Kafka event schemas** — JSON Schema draft-07 definitions for all 11 event types used in domain event streaming.
- **Infrastructure** — `docker-compose.yml` to spin up the entire data stack locally with a single command.

### What problems it solves

| Problem | Solution |
|---|---|
| Market tick data at high cardinality | TimescaleDB hypertables with time + symbol partitioning |
| Cross-project user identity | Single `shared.users` table referenced by all domains |
| Fast full-text search on 20 000+ instruments | Elasticsearch with custom analyzers for ticker/company lookup |
| Real-time price dissemination | Redis Pub/Sub channels per symbol, TTL-backed LTP hashes |
| Audit trail for all domain events | Immutable `event_store` hypertable + PostgreSQL audit triggers |
| Schema isolation without separate databases | PostgreSQL schema-per-project with cross-schema FKs |
| Repeatable local dev setup | Docker Compose + idempotent `init_all.sh` |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Client Applications                          │
│           ScreenerX Web  │  QuantNova Terminal  │  NDFL Portal      │
└──────────────┬───────────┴──────────┬───────────┴────────┬──────────┘
               │                      │                     │
               ▼                      ▼                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          API / Backend Layer                        │
│               NestJS / FastAPI services per domain                  │
└──────┬────────────────┬──────────────────┬───────────────┬──────────┘
       │                │                  │               │
       ▼                ▼                  ▼               ▼
┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│ PostgreSQL  │  │    Redis    │  │Elasticsearch │  │    Kafka     │
│  (pg16 +   │  │   (7-alp)  │  │   (8.13)     │  │  (CP 7.6)    │
│ TimescaleDB)│  │             │  │              │  │              │
│             │  │ • LTP hash  │  │ • stocks idx │  │ • tick.raw   │
│ shared      │  │ • sessions  │  │ • news idx   │  │ • order.evt  │
│ screenerx   │  │ • screener  │  │              │  │ • alert.evt  │
│ quantnova   │  │   cache     │  │              │  │ • signal.evt │
│ ndfl        │  │ • nav cache │  │              │  │ • filing.evt │
└─────────────┘  └─────────────┘  └──────────────┘  └──────────────┘
       │
       ├── shared schema    ──▶  users, roles, sessions, billing
       ├── screenerx schema ──▶  markets, fundamentals, screener, portfolios
       ├── quantnova schema ──▶  orders, strategies, backtests, ML models
       └── ndfl schema      ──▶  tax years, income, capital gains, TDS
```

**Data flow for a live market tick:**

```
Exchange Feed → Kafka topic: tick.raw
    → Consumer writes to market_data_ticks (TimescaleDB hypertable)
    → Consumer updates Redis hash: market:price:{symbol_id}
    → Consumer publishes to Redis channel: ticks:{exchange}:{symbol_id}
    → WebSocket gateway fans out to subscribed clients
    → Continuous aggregate cagg_market_data_5m materialised every 5 minutes
```

---

## Project Domains

| Domain | PostgreSQL Schema | Tables | Description |
|---|---|---|---|
| `shared` | `shared` | 15 | Cross-project identity, auth, billing, notifications, and (v1.3.0) advisor workflow tables. Referenced by all other schemas. |
| `screenerx` | `screenerx` | 59 | Stock screener and portfolio management — markets, fundamentals, screener engine, portfolios, watchlists, alerts, market indices, FII/DII, IPOs, economic calendar, analytics, and (v1.3.0) 9 AI platform tables. |
| `quantnova` | `quantnova` | 23 | Quantitative trading and AI/ML — brokers, orders, executions, positions, strategies, backtests, feature store, ML models, inference logs. |
| `ndfl` | `ndfl` | 8 | Indian income tax and compliance — tax years, income sources, capital gains, TDS records, Form 26AS, computations, payments, documents. |

**Total: 105 tables across 4 schemas** (including 11 new AI platform tables added in v1.3.0).

---

## Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| PostgreSQL | 16 | Primary relational store; schema-per-domain multi-tenancy |
| TimescaleDB | latest-pg16 | Time-series extension; 18 hypertables for market data, P&L, and ML logs |
| Redis | 7-alpine | LTP cache, session store, screener cache, alert cooldowns, pub/sub |
| Elasticsearch | 8.13.0 | Full-text search for instruments and news articles |
| Apache Kafka | CP 7.6.0 | Domain event streaming — 11 event schemas across all domains |
| Confluent Schema Registry | 7.6.0 | Kafka JSON Schema management and compatibility enforcement |
| Docker Compose | 3.9 | Local infrastructure orchestration |

---

## Repository Structure

```
database/
│
├── shared/                              # Cross-project domain (schema: shared)
│   ├── postgres/
│   │   ├── ddl/
│   │   │   ├── 000_extensions.sql       # uuid-ossp, pgcrypto, pg_trgm, btree_gin
│   │   │   ├── 000_enums.sql            # 35 enum types across all domains
│   │   │   ├── 001_users.sql            # Core user accounts
│   │   │   ├── 002_roles.sql            # RBAC role definitions
│   │   │   ├── 003_permissions.sql      # Granular permission catalogue
│   │   │   ├── 004_user_roles.sql       # User ↔ role junction
│   │   │   ├── 005_sessions.sql         # JWT / device sessions
│   │   │   ├── 006_api_keys.sql         # API key authentication
│   │   │   ├── 007_subscriptions.sql    # Stripe subscription records
│   │   │   ├── 008_billing_transactions.sql  # Payment history
│   │   │   ├── 009_audit_logs.sql       # Full-table change audit trail
│   │   │   ├── 010_user_preferences.sql # Per-user settings (JSONB)
│   │   │   ├── 011_devices.sql          # Push notification device tokens
│   │   │   ├── 012_oauth_accounts.sql   # Google/GitHub/etc. OAuth links
│   │   │   ├── 013_notifications.sql    # In-app & push notifications
│   │   │   ├── 014_advisor_clients.sql  # Advisor-client relationships (v1.3.0)
│   │   │   └── 015_advisor_approvals.sql # Human-in-loop approval workflow (v1.3.0)
│   │   ├── dml/
│   │   │   └── seed_001_users.sql       # 15 seed users across all tenants
│   │   ├── indexes/
│   │   │   ├── idx_users.sql
│   │   │   ├── idx_sessions.sql
│   │   │   ├── idx_api_keys.sql
│   │   │   └── idx_audit_logs.sql
│   │   ├── triggers/
│   │   │   └── users_trigger.sql        # updated_at auto-maintenance
│   │   ├── functions/
│   │   │   ├── audit_trigger_function.sql  # Generic audit log writer
│   │   │   └── soft_delete_function.sql    # Soft-delete helper
│   │   └── migrations/
│   │       └── 001_create_schema.sql    # Idempotent full-schema migration
│   ├── redis/
│   │   └── key_schemas.md               # Session, rate-limit, token key patterns
│   └── kafka/
│       └── schemas/
│           ├── user_event.json          # User lifecycle events
│           └── notification_event.json  # Notification delivery events
│
├── screenerx/                           # Stock screener platform (schema: screenerx)
│   ├── postgres/
│   │   ├── ddl/
│   │   │   ├── 014_exchanges.sql        # Exchange master (NSE, BSE, NYSE…)
│   │   │   ├── 015_symbols.sql          # Instrument master
│   │   │   ├── 016_instrument_master.sql # Extended instrument metadata
│   │   │   ├── 017_market_data_ticks.sql # Tick data (hypertable)
│   │   │   ├── 018_market_data_ohlcv.sql # Multi-timeframe OHLCV (hypertables)
│   │   │   ├── 019_order_books.sql      # L2 order book snapshots (hypertable)
│   │   │   ├── 020_corporate_actions.sql
│   │   │   ├── 021_dividends.sql
│   │   │   ├── 022_splits.sql
│   │   │   ├── 023_earnings.sql
│   │   │   ├── 024_economic_events.sql
│   │   │   ├── 025_news_articles.sql
│   │   │   ├── 026_sentiment_data.sql   # NLP sentiment (hypertable)
│   │   │   ├── 027_companies.sql
│   │   │   ├── 028_balance_sheets.sql
│   │   │   ├── 029_income_statements.sql
│   │   │   ├── 030_cash_flows.sql
│   │   │   ├── 031_financial_ratios.sql  # Daily ratios (hypertable)
│   │   │   ├── 032_shareholding_patterns.sql
│   │   │   ├── 033_mutual_fund_holdings.sql
│   │   │   ├── 034_institutional_holdings.sql
│   │   │   ├── 035_analyst_ratings.sql
│   │   │   ├── 036_screener_templates.sql
│   │   │   ├── 037_screener_filters.sql
│   │   │   ├── 038_saved_screeners.sql
│   │   │   ├── 039_screener_results_cache.sql
│   │   │   ├── 040_screener_executions.sql
│   │   │   ├── 041_custom_formulas.sql
│   │   │   ├── 042_portfolios.sql
│   │   │   ├── 043_portfolio_positions.sql
│   │   │   ├── 044_portfolio_transactions.sql
│   │   │   ├── 045_portfolio_snapshots.sql   # EOD snapshots (hypertable)
│   │   │   ├── 046_portfolio_performance.sql # Daily perf (hypertable)
│   │   │   ├── 047_watchlists.sql
│   │   │   ├── 048_watchlist_items.sql
│   │   │   ├── 049_goals.sql
│   │   │   ├── 050_rebalancing_rules.sql
│   │   │   ├── 073_alerts.sql
│   │   │   ├── 074_alert_events.sql     # Alert trigger log (hypertable)
│   │   │   ├── 076_websocket_sessions.sql
│   │   │   ├── 077_kpi_metrics.sql      # Platform KPIs (hypertable)
│   │   │   ├── 078_user_activity.sql    # Behavioural events (hypertable)
│   │   │   ├── 079_search_logs.sql
│   │   │   ├── 080_market_indices.sql   # Index snapshots with sparklines (v1.1.0)
│   │   │   ├── 081_fii_dii_activity.sql # FII/DII daily activity (v1.1.0)
│   │   │   ├── 082_ipos.sql             # IPO tracker (v1.1.0)
│   │   │   ├── 083_ai_copilot_sessions.sql      # AI chat sessions (v1.3.0)
│   │   │   ├── 084_ai_copilot_messages.sql      # Chat messages with token tracking (v1.3.0)
│   │   │   ├── 085_risk_profiles.sql            # SEBI risk-o-meter profiles (v1.3.0)
│   │   │   ├── 086_financial_goals.sql          # Goal planning with Monte Carlo (v1.3.0)
│   │   │   ├── 087_retirement_plans.sql         # Retirement corpus planning (v1.3.0)
│   │   │   ├── 088_portfolio_analyses.sql       # Sharpe/Sortino analytics (v1.3.0)
│   │   │   ├── 089_ai_investment_recommendations.sql # Personalized AI recs (v1.3.0)
│   │   │   ├── 090_market_intelligence_summaries.sql # Cached AI summaries (v1.3.0)
│   │   │   └── 091_financial_health_scores.sql  # Composite health scores (v1.3.0)
│   │   ├── dml/
│   │   │   ├── seed_002_exchanges.sql   # 8 exchanges
│   │   │   ├── seed_003_symbols.sql     # 20 instruments
│   │   │   ├── seed_004_companies.sql   # 8 companies with corporate data
│   │   │   ├── seed_005_market_data.sql # 975 OHLCV records
│   │   │   ├── seed_006_portfolios.sql  # 5 portfolios with positions
│   │   │   ├── seed_007_screeners.sql   # Sample screener templates
│   │   │   ├── seed_010_market_indices.sql  # 15 index snapshots (v1.1.0)
│   │   │   ├── seed_011_fii_dii.sql     # 10 days FII/DII data (v1.1.0)
│   │   │   ├── seed_012_ipos.sql        # 7 IPOs (v1.1.0)
│   │   │   └── seed_013_economic_events.sql # 10 macro events (v1.1.0)
│   │   ├── indexes/
│   │   │   ├── idx_symbols.sql
│   │   │   ├── idx_market_data.sql
│   │   │   ├── idx_fundamentals.sql
│   │   │   ├── idx_screener.sql
│   │   │   ├── idx_portfolio.sql
│   │   │   └── idx_alerts_events.sql
│   │   ├── triggers/
│   │   │   ├── alert_trigger.sql
│   │   │   └── portfolio_trigger.sql
│   │   ├── views/
│   │   │   ├── v_stock_overview.sql
│   │   │   ├── v_portfolio_holdings.sql
│   │   │   └── v_active_alerts.sql
│   │   ├── materialized_views/
│   │   │   ├── mv_stock_daily_summary.sql
│   │   │   ├── mv_sector_performance.sql
│   │   │   ├── mv_portfolio_summary.sql
│   │   │   └── mv_top_movers.sql
│   │   ├── functions/
│   │   │   ├── portfolio_value_function.sql
│   │   │   └── screener_execute_function.sql
│   │   └── migrations/
│   │       └── 001_create_schema.sql
│   ├── timescaledb/
│   │   ├── hypertables/
│   │   │   └── create_hypertables.sql   # 18 hypertable declarations
│   │   ├── continuous_aggregates/
│   │   │   ├── cagg_market_data_1h.sql
│   │   │   ├── cagg_market_data_5m.sql
│   │   │   └── cagg_daily_volume_profile.sql
│   │   ├── compression/
│   │   │   └── compression_policies.sql
│   │   └── retention/
│   │       └── retention_policies.sql
│   ├── redis/
│   │   └── key_schemas.md               # Price, order book, screener, portfolio key patterns
│   ├── elasticsearch/
│   │   └── mappings/
│   │       ├── stocks_mapping.json
│   │       └── news_mapping.json
│   └── kafka/
│       └── schemas/
│           ├── market_tick_event.json
│           ├── alert_triggered_event.json
│           └── portfolio_updated_event.json
│
├── quantnova/                           # Quant trading & ML platform (schema: quantnova)
│   ├── postgres/
│   │   ├── ddl/
│   │   │   ├── 051_brokers.sql
│   │   │   ├── 052_broker_accounts.sql
│   │   │   ├── 053_orders.sql
│   │   │   ├── 054_order_fills.sql
│   │   │   ├── 055_executions.sql
│   │   │   ├── 056_positions.sql
│   │   │   ├── 057_risk_limits.sql
│   │   │   ├── 058_pnl_snapshots.sql    # Intraday P&L (hypertable)
│   │   │   ├── 059_strategies.sql
│   │   │   ├── 060_strategy_versions.sql
│   │   │   ├── 061_backtests.sql
│   │   │   ├── 062_backtest_results.sql
│   │   │   ├── 063_optimization_runs.sql
│   │   │   ├── 064_alpha_signals.sql    # Strategy signals (hypertable)
│   │   │   ├── 065_ml_models.sql
│   │   │   ├── 066_model_versions.sql
│   │   │   ├── 067_feature_store.sql
│   │   │   ├── 068_feature_values.sql   # Feature history (hypertable)
│   │   │   ├── 069_training_runs.sql
│   │   │   ├── 070_inference_logs.sql   # Prediction audit (hypertable)
│   │   │   ├── 071_ai_recommendations.sql
│   │   │   ├── 072_drift_detection.sql
│   │   │   └── 075_event_store.sql      # Domain event log (hypertable)
│   │   ├── dml/
│   │   │   └── seed_008_trading.sql     # 5 brokers, 3 strategies
│   │   ├── indexes/
│   │   │   ├── idx_trading.sql
│   │   │   ├── idx_strategies.sql
│   │   │   └── idx_ml.sql
│   │   ├── triggers/
│   │   │   └── orders_trigger.sql
│   │   └── migrations/
│   │       └── 001_create_schema.sql
│   ├── redis/
│   │   └── key_schemas.md               # Order state, position, risk key patterns
│   └── kafka/
│       └── schemas/
│           ├── order_event.json
│           ├── signal_event.json
│           ├── execution_event.json
│           └── risk_event.json
│
├── ndfl/                                # Tax & compliance platform (schema: ndfl)
│   ├── postgres/
│   │   ├── ddl/
│   │   │   ├── 001_tax_years.sql        # ITR filing records per user
│   │   │   ├── 002_income_sources.sql   # Salary, business, other income
│   │   │   ├── 003_capital_gains.sql    # STCG / LTCG per transaction
│   │   │   ├── 004_tds_records.sql      # TDS deductions (Form 16/16A)
│   │   │   ├── 005_form26as.sql         # Form 26AS import records
│   │   │   ├── 006_tax_computations.sql # Computed tax liability
│   │   │   ├── 007_tax_payments.sql     # Advance tax / self-assessment payments
│   │   │   └── 008_tax_documents.sql    # Document uploads and metadata
│   │   ├── dml/                         # (seed data not yet populated)
│   │   └── migrations/
│   │       └── 001_create_schema.sql
│   └── kafka/
│       └── schemas/
│           ├── tax_event.json
│           └── filing_event.json
│
└── infra/                               # Infrastructure configuration
    ├── docker-compose.yml               # Full local stack (pg, redis, es, kafka, zookeeper, schema-registry)
    └── scripts/
        ├── init_shared.sh
        ├── init_screenerx.sh
        ├── init_quantnova.sh
        ├── init_ndfl.sh
        └── init_all.sh                  # Run all schemas in dependency order
```

---

## Quick Start

### Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Git | Clone repo | [git-scm.com](https://git-scm.com) |
| `psql` | Run migrations | [PostgreSQL downloads](https://www.postgresql.org/download/) or `brew install libpq` |
| Docker + Compose | Local full stack | [docker.com](https://www.docker.com/products/docker-desktop) |
| Python 3 | Alternative migration runner | [python.org](https://www.python.org) |

---

### Option A — Neon (Cloud PostgreSQL, recommended for development)

**No Docker needed. Free tier at [neon.tech](https://neon.tech).**

#### 1. Clone the repo

```bash
git clone https://github.com/nitindantu/finstack-db.git
cd finstack-db
```

#### 2. Create a Neon database

1. Sign up at [neon.tech](https://neon.tech) — free, no credit card
2. Create a new project
3. Copy the connection string — looks like:
   ```
   postgresql://user:pass@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require
   ```

#### 3. Set your connection string

```bash
export DATABASE_URL="postgresql://user:pass@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require"
```

#### 4. Run migrations with Python (no psql needed)

```bash
pip install psycopg2-binary

python3 - <<'EOF'
import psycopg2, os

conn = psycopg2.connect(os.environ['DATABASE_URL'])
conn.autocommit = True
cur = conn.cursor()

# Create schemas
for schema in ['shared', 'screenerx', 'quantnova', 'ndfl']:
    cur.execute(f'CREATE SCHEMA IF NOT EXISTS {schema};')
    print(f'  schema {schema} ready')

# Install extensions
for ext in ['uuid-ossp', 'pgcrypto', 'pg_trgm', 'btree_gin']:
    try:
        cur.execute(f'CREATE EXTENSION IF NOT EXISTS "{ext}";')
    except: pass

print('Done. Run migration files next.')
conn.close()
EOF
```

#### 5. Run migration files in order

```bash
# shared domain (always first)
psql "$DATABASE_URL" -f shared/postgres/ddl/000_extensions.sql
psql "$DATABASE_URL" -f shared/postgres/ddl/000_enums.sql
psql "$DATABASE_URL" -f shared/postgres/migrations/001_create_schema.sql

# screenerx domain
psql "$DATABASE_URL" -f screenerx/postgres/migrations/001_create_schema.sql

# quantnova domain
psql "$DATABASE_URL" -f quantnova/postgres/migrations/001_create_schema.sql

# ndfl domain
psql "$DATABASE_URL" -f ndfl/postgres/migrations/001_create_schema.sql
```

Or run everything at once:

```bash
chmod +x infra/scripts/init_all.sh
./infra/scripts/init_all.sh
```

#### 6. Load seed data

```bash
psql "$DATABASE_URL" -f shared/postgres/dml/seed_001_users.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_002_exchanges.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_003_symbols.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_004_companies.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_005_market_data.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_006_portfolios.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_007_screeners.sql
psql "$DATABASE_URL" -f quantnova/postgres/dml/seed_008_trading.sql
```

#### 7. Verify

```bash
psql "$DATABASE_URL" -c "\dn"
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM shared.users;"
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM screenerx.symbols;"
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM screenerx.market_data_1d;"
```

Expected output:
```
 count
-------
    15     ← users
    20     ← symbols
   975     ← market data rows
```

---

### Option B — Docker (Local Full Stack)

**Runs PostgreSQL + TimescaleDB + Redis + Elasticsearch + Kafka locally.**

#### 1. Clone and start infrastructure

```bash
git clone https://github.com/nitindantu/finstack-db.git
cd finstack-db

# Start all services
docker compose -f infra/docker-compose.yml up -d

# Wait for PostgreSQL to be ready (takes ~15 seconds)
docker compose -f infra/docker-compose.yml exec postgres pg_isready -U postgres -d finstack
```

#### 2. Set connection string

```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"
```

#### 3. Run all migrations

```bash
chmod +x infra/scripts/*.sh
./infra/scripts/init_all.sh
```

#### 4. Enable TimescaleDB hypertables (local only)

```bash
psql "$DATABASE_URL" -f screenerx/timescaledb/hypertables/create_hypertables.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/compression/compression_policies.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/retention/retention_policies.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_5m.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_1h.sql
```

#### 5. Check running services

```bash
docker compose -f infra/docker-compose.yml ps
```

| Service | Port | URL |
|---------|------|-----|
| PostgreSQL + TimescaleDB | 5432 | `postgres://postgres:postgres@localhost:5432/finstack` |
| Redis | 6379 | `redis://localhost:6379` |
| Elasticsearch | 9200 | http://localhost:9200 |
| Kafka | 9092 | `localhost:9092` |

#### 6. Stop services

```bash
docker compose -f infra/docker-compose.yml down

# To also delete all data volumes
docker compose -f infra/docker-compose.yml down -v
```

---

### Option C — Run Individual Domains

```bash
export DATABASE_URL="your_connection_string"

# shared must always run first (other domains depend on shared.users)
./infra/scripts/init_shared.sh

# then run whichever domains you need
./infra/scripts/init_screenerx.sh
./infra/scripts/init_quantnova.sh
./infra/scripts/init_ndfl.sh
```

---

### Migration dependency order

```
shared/          ← must run first (users, auth, billing)
   │
   ├── screenerx/    ← references shared.users
   ├── quantnova/    ← references shared.users + screenerx.symbols
   └── ndfl/         ← references shared.users
```

> **TimescaleDB note:** Hypertable features (`create_hypertable`, compression, continuous aggregates) require a self-hosted PostgreSQL with the TimescaleDB extension. On Neon or plain PostgreSQL, all 105 tables are created normally — only skip the `timescaledb/` scripts.

---

## Schema Descriptions

### `shared` — Identity, Auth & Billing

The `shared` schema is the foundation of the entire platform. Every user account lives here; all other schemas reference `shared.users` via foreign keys.

- **users** — Core account records with multi-tenancy via `tenant_id`. Supports password auth and OAuth.
- **roles / permissions / user_roles** — RBAC system. Roles are named (admin, analyst, viewer, trader). Permissions are granular resource-action pairs.
- **sessions** — JWT-backed login sessions with device fingerprinting and refresh token rotation.
- **api_keys** — Hashed API keys for programmatic access with per-key scopes.
- **subscriptions** — Stripe-backed plan subscriptions (free / basic / premium / enterprise).
- **billing_transactions** — Immutable payment history linked to subscriptions.
- **audit_logs** — Generic change audit table populated by trigger on every mutating operation.
- **user_preferences** — JSONB key-value store for per-user application settings.
- **devices** — Push notification device tokens (iOS / Android / Web).
- **oauth_accounts** — OAuth provider links (Google, GitHub, Facebook, Twitter, LinkedIn).
- **notifications** — In-app, push, email, and SMS notification records.
- **advisor_clients** (v1.3.0) — Advisor-client relationships for SEBI-registered advisor workflows.
- **advisor_approvals** (v1.3.0) — Human-in-loop approval queue for AI investment recommendations above configurable conviction threshold.

### `screenerx` — Stock Screener & Portfolio

The largest domain (59 tables as of v1.3.0) covering the full lifecycle of a stock screening and portfolio management application.

**Market Data sub-group:** exchanges, symbols, instrument_master, market_data_ticks (hypertable), market_data_ohlcv (6 timeframe hypertables), order_books (hypertable).

**Corporate Events sub-group:** corporate_actions, dividends, splits, earnings, economic_events.

**News & Sentiment sub-group:** news_articles, sentiment_data (hypertable).

**Fundamentals sub-group:** companies, balance_sheets, income_statements, cash_flows, financial_ratios (hypertable), shareholding_patterns, mutual_fund_holdings, institutional_holdings, analyst_ratings.

**Screener Engine sub-group:** screener_templates, screener_filters, saved_screeners, screener_results_cache, screener_executions, custom_formulas.

**Portfolio sub-group:** portfolios, portfolio_positions, portfolio_transactions, portfolio_snapshots (hypertable), portfolio_performance (hypertable), goals, rebalancing_rules.

**Watchlists:** watchlists, watchlist_items.

**Alerts:** alerts, alert_events (hypertable).

**Analytics:** websocket_sessions, kpi_metrics (hypertable), user_activity (hypertable), search_logs.

**Dashboard sub-group (v1.1.0):** market_indices, fii_dii_activity, ipos.

**AI Platform sub-group (v1.3.0):** ai_copilot_sessions, ai_copilot_messages, risk_profiles, financial_goals, retirement_plans, portfolio_analyses, ai_investment_recommendations, market_intelligence_summaries, financial_health_scores.

### `quantnova` — Quantitative Trading & AI/ML

23 tables powering a full-stack algorithmic trading and machine learning research platform.

**Brokerage sub-group:** brokers, broker_accounts.

**Order Management sub-group:** orders, order_fills, executions, positions, risk_limits, pnl_snapshots (hypertable).

**Strategy sub-group:** strategies, strategy_versions, backtests, backtest_results, optimization_runs, alpha_signals (hypertable).

**AI/ML sub-group:** ml_models, model_versions, feature_store, feature_values (hypertable), training_runs, inference_logs (hypertable), ai_recommendations, drift_detection.

**Event Sourcing:** event_store (hypertable) — immutable domain event log for audit and replay.

### `ndfl` — Indian Tax & Compliance

8 tables covering the Indian income tax return workflow from data collection to filing.

- **tax_years** — One record per user per assessment year. Tracks filing status, ITR form type, and summary totals.
- **income_sources** — Salary, business income, house property, and other income heads.
- **capital_gains** — Individual security sale transactions with STCG / LTCG classification.
- **tds_records** — TDS deductions from Form 16 / Form 16A uploads.
- **form26as** — Parsed Form 26AS records imported from TRACES.
- **tax_computations** — Computed tax liability with deductions (80C, 80D, etc.) applied.
- **tax_payments** — Advance tax and self-assessment tax challan records.
- **tax_documents** — Document storage metadata (Form 16, computation sheets, ITR acknowledgement).

---

## Connecting to the Database

### Local (Docker)

```
postgresql://postgres:postgres@localhost:5432/finstack
```

### Neon (Cloud PostgreSQL)

```
postgresql://<user>:<password>@<project-id>.neon.tech/finstack?sslmode=require
```

Set the connection string as an environment variable:

```bash
export DATABASE_URL="postgresql://<user>:<password>@<host>.neon.tech/finstack?sslmode=require"
```

In application code (Node.js / Python):

```typescript
// Node.js
import { Pool } from 'pg';
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
```

```python
# Python
import psycopg2
conn = psycopg2.connect(os.environ['DATABASE_URL'])
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `postgres://postgres:postgres@localhost:5432/finstack` | Full PostgreSQL connection string |
| `POSTGRES_USER` | `postgres` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL password |
| `POSTGRES_DB` | `finstack` | Database name |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `REDIS_PASSWORD` | `redispass` | Redis AUTH password |
| `REDIS_PORT` | `6379` | Redis port |
| `KAFKA_PORT` | `9092` | Kafka broker port |
| `ELASTICSEARCH_PORT` | `9200` | Elasticsearch HTTP port |
| `SCHEMA_REGISTRY_PORT` | `8081` | Confluent Schema Registry port |
| `ZOOKEEPER_PORT` | `2181` | Zookeeper client port |

---

## CI/CD Pipeline

As of **v1.2.0**, all migrations run automatically through GitHub Actions. Manual `psql` is only needed for local development.

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `validate.yml` | Every PR | SQL lint, naming convention check, destructive statement detector, **Neon branch dry-run** (real ephemeral branch → run all migrations → verify counts → delete branch), schema diff PR comment |
| `migrate-staging.yml` | Push to `main` (SQL files changed) | Applies all domain migrations + seed data to Neon staging automatically |
| `migrate-production.yml` | Push of `v*.*.*` tag | Applies migrations to Neon production with **manual approval gate** in GitHub Environments |
| `release.yml` | Push to `main` | semantic-release: conventional commits → semver bump → `CHANGELOG.md` → GitHub Release + tag |

### Deployment flow

```
feature branch → PR
  └── validate.yml: dry-run on ephemeral Neon branch
        ↓ PR merged to main
  └── migrate-staging.yml: auto-deploy to staging
        ↓ staging verified, tag pushed (vX.Y.Z)
  └── migrate-production.yml: approve in GitHub → deploy to production
```

### Required GitHub Secrets

| Secret | Used by |
|--------|---------|
| `STAGING_DATABASE_URL` | migrate-staging |
| `PRODUCTION_DATABASE_URL` | migrate-production |
| `NEON_API_KEY` | validate dry-run |
| `NEON_PROJECT_ID` | validate dry-run |
| `STAGING_DB_PASSWORD` | validate dry-run |

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full contribution guide including conventional commits, migration rules, and branch strategy.

**Quick rules:**
1. **Schema changes** — Always add a new DDL file (`NNN_table_name.sql`) rather than modifying existing ones in production.
2. **Migrations are additive only** — `CREATE TABLE`, `ADD COLUMN` (nullable/default), `CREATE INDEX CONCURRENTLY`. Never `DROP` in a production migration.
3. **Enums** — Add to `shared/postgres/ddl/000_enums.sql`. Do not create domain-local enum files.
4. **Indexes** — Add to the appropriate `indexes/idx_*.sql` file, never inline in DDL.
5. **Seeds** — Fixed UUIDs, idempotent `INSERT ... ON CONFLICT DO NOTHING`.
6. **Naming** — Tables: `snake_case` plural. Columns: `snake_case`. PKs: `id UUID`. FKs: `{table_singular}_id`.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for deep-dive design rationale.

---

## License

MIT © Finstack. See [LICENSE](LICENSE) for full text.
