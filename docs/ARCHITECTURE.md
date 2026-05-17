# Architecture Deep-Dive

## Table of Contents

- [Polyglot Persistence Decision Rationale](#polyglot-persistence-decision-rationale)
- [PostgreSQL Schema-per-Project Design Pattern](#postgresql-schema-per-project-design-pattern)
- [Why Schemas Over Separate Databases](#why-schemas-over-separate-databases)
- [Data Flow Diagrams](#data-flow-diagrams)
- [Cross-Schema Foreign Key Strategy](#cross-schema-foreign-key-strategy)
- [Multi-Tenancy Approach](#multi-tenancy-approach)
- [TimescaleDB Hypertable Strategy](#timescaledb-hypertable-strategy)
- [Redis Caching Strategy](#redis-caching-strategy)
- [Elasticsearch Indexing Strategy](#elasticsearch-indexing-strategy)
- [Kafka Event Streaming Architecture](#kafka-event-streaming-architecture)
- [Security: RLS Policies and Schema Isolation](#security-rls-policies-and-schema-isolation)
- [Scalability Considerations](#scalability-considerations)

---

## Polyglot Persistence Decision Rationale

finstack-db uses five distinct storage technologies, each chosen because no single engine handles all access patterns efficiently:

| Access Pattern | Volume / Frequency | Technology Chosen | Reason |
|---|---|---|---|
| Relational OLTP — user accounts, orders, portfolios | Moderate, transactional | PostgreSQL 16 | ACID guarantees, complex joins, FK enforcement |
| Time-series — tick data, OHLCV candles, P&L snapshots | Very high, append-mostly | TimescaleDB (PostgreSQL extension) | Automatic chunk pruning, continuous aggregates, native SQL |
| Hot key-value reads — latest price, session tokens | Extremely high, sub-millisecond SLA | Redis 7 | O(1) hash lookups, pub/sub fanout, no disk I/O |
| Full-text / faceted search — instrument and news search | High, read-heavy | Elasticsearch 8.13 | Inverted index, custom tokenisers, relevance scoring |
| Domain event streaming — decoupled async workflows | High, ordered delivery | Apache Kafka CP 7.6 | Durable log, consumer groups, exactly-once semantics |

**What was rejected and why:**

- *MongoDB for user data* — rejected because rich relational structure (RBAC, billing, multi-tenancy) benefits from FK enforcement and JOIN semantics.
- *InfluxDB for time-series* — rejected because TimescaleDB runs on the existing PostgreSQL cluster, shares the same connection pool, and supports SQL-standard queries without a separate driver.
- *DynamoDB for sessions* — rejected to avoid AWS lock-in; Redis provides equivalent latency with simpler operations.

---

## PostgreSQL Schema-per-Project Design Pattern

Each project domain occupies its own PostgreSQL **schema** (namespace) within the single `finstack` database:

```sql
CREATE SCHEMA IF NOT EXISTS shared;
CREATE SCHEMA IF NOT EXISTS screenerx;
CREATE SCHEMA IF NOT EXISTS quantnova;
CREATE SCHEMA IF NOT EXISTS ndfl;
```

All DDL is **schema-qualified**:

```sql
CREATE TABLE screenerx.portfolios ( ... );
CREATE TABLE quantnova.orders ( ... );
```

This pattern is enforced by the `search_path` setting on each application role:

```sql
-- ScreenerX application role
ALTER ROLE screenerx_app SET search_path = screenerx, shared, public;

-- QuantNova application role
ALTER ROLE quantnova_app SET search_path = quantnova, screenerx, shared, public;
```

---

## Why Schemas Over Separate Databases

The alternative was to create four separate PostgreSQL databases (`finstack_shared`, `finstack_screenerx`, etc.). Schemas were chosen for the following reasons:

**For schemas:**

1. **Cross-schema foreign keys are supported natively.** `quantnova.orders` references `screenerx.symbols` and `screenerx.portfolios`. Cross-database FKs are not possible in PostgreSQL without extensions like `postgres_fdw`.
2. **Single connection pool.** Applications can join across all schemas in one query without round-trips. A `portfolios` view that includes `shared.users.full_name` requires no distributed join.
3. **Single migration runner.** One `psql` session initialises everything. One Docker Compose service. One backup target (`pg_dump finstack`).
4. **Shared extensions.** `uuid-ossp`, `pgcrypto`, `pg_trgm`, and `btree_gin` are installed once and available to all schemas.
5. **Operational simplicity.** One set of connection credentials for monitoring, alerting, and disaster recovery.

**Remaining isolation:**

1. **Permission grants per schema** — application roles are granted only the privileges they need on their own schema plus `SELECT` on shared.
2. **Row-Level Security** — the `tenant_id` column on core tables (users, portfolios, etc.) is enforced at the row level via RLS policies, preventing cross-tenant data leakage even if a role has broad schema access.

---

## Data Flow Diagrams

### Live Market Tick Flow

```
Exchange WebSocket Feed
        │
        ▼
  Kafka Producer
  Topic: tick.raw
  Key: {exchange_code}:{symbol_id}
        │
        ├──▶ TimescaleDB Consumer
        │       COPY INTO screenerx.market_data_ticks
        │       (chunk interval: 1 day, space partition on symbol_id x16)
        │
        ├──▶ Redis LTP Consumer
        │       HSET market:price:{symbol_id}
        │         ltp, open, high, low, close, volume, bid, ask, change_pct
        │       TTL: 300s (refreshed on every tick)
        │
        └──▶ WebSocket Gateway Consumer
                PUBLISH ticks:{exchange}:{symbol_id}
                → Fan-out to all subscribed client connections
```

### Screener Execution Flow

```
Client Request: POST /screener/run
        │
        ▼
  API Layer
        │
        ├── Cache Check
        │     GET screener:cache:{SHA256(filter_json)}
        │     HIT  → return cached result (< 300s old)
        │     MISS → continue
        │
        ▼
  screener_execute_function(filter_json)
        │   PostgreSQL function evaluates each filter against
        │   screenerx.symbols JOIN financial_ratios JOIN market_data_ohlcv
        │
        ▼
  Result set → INSERT INTO screenerx.screener_results_cache
        │
        ▼
  SET screener:cache:{hash}  TTL 300s
        │
        ▼
  Response to client
```

### Order Lifecycle Flow

```
Client: Place Order
        │
        ▼
  quantnova.orders (status: pending)
        │
        ├── Risk limit check → quantnova.risk_limits
        │     BREACH? → status: rejected, publish risk_event to Kafka
        │     OK?     → continue
        │
        ▼
  Broker API submission
        │
        ├── quantnova.orders (status: open / partial / filled)
        │
        ├── quantnova.order_fills  (each partial fill)
        │
        ├── quantnova.executions   (confirmed execution records)
        │
        └── screenerx.portfolio_positions  (position update)
              └── screenerx.portfolio_transactions (transaction record)
                    └── Kafka: portfolio_updated_event
                          └── Redis: HSET portfolio:positions:{portfolio_id}
```

### Full Platform Data Flow

```
┌──────────────┐     REST/WS     ┌────────────────────────────────────┐
│   Web / App  │ ◀─────────────▶ │         Backend API Services        │
│   Clients    │                 │  ScreenerX  │ QuantNova │   NDFL    │
└──────────────┘                 └──────┬──────┴─────┬─────┴─────┬─────┘
                                        │            │           │
               ┌────────────────────────┼────────────┼───────────┤
               │                        │            │           │
               ▼                        ▼            ▼           ▼
     ┌──────────────────┐    ┌────────────────────────────────────────┐
     │  Redis (cache)   │    │         PostgreSQL (finstack db)        │
     │                  │    │                                        │
     │ market:price:*   │◀──▶│  shared.*    screenerx.*              │
     │ portfolio:nav:*  │    │  quantnova.* ndfl.*                   │
     │ screener:cache:* │    │                                        │
     │ sessions:*       │    │  TimescaleDB hypertables:              │
     │ alert:cooldown:* │    │  market_data_ticks, pnl_snapshots,     │
     └──────────────────┘    │  alpha_signals, inference_logs, etc.  │
                              └────────────────────────────────────────┘
               │
               ▼
     ┌──────────────────┐    ┌──────────────────┐
     │  Kafka Broker    │    │  Elasticsearch   │
     │                  │    │                  │
     │  tick.raw        │    │  stocks index    │
     │  order.events    │    │  news index      │
     │  alert.events    │    │                  │
     │  portfolio.events│    │  Full-text search│
     │  signal.events   │    │  ticker lookup   │
     │  execution.events│    │  news search     │
     │  risk.events     │    └──────────────────┘
     │  tax.events      │
     │  filing.events   │
     │  user.events     │
     │  notif.events    │
     └──────────────────┘
```

---

## Cross-Schema Foreign Key Strategy

All cross-schema references are fully qualified and use `ON DELETE RESTRICT` by default to prevent orphaned records:

```sql
-- quantnova.orders references shared.users
CONSTRAINT orders_user_fk FOREIGN KEY (user_id)
    REFERENCES shared.users (id) ON DELETE RESTRICT

-- quantnova.orders references screenerx.symbols
CONSTRAINT orders_symbol_fk FOREIGN KEY (symbol_id)
    REFERENCES screenerx.symbols (id) ON DELETE RESTRICT

-- quantnova.orders references screenerx.portfolios
CONSTRAINT orders_portfolio_fk FOREIGN KEY (portfolio_id)
    REFERENCES screenerx.portfolios (id) ON DELETE SET NULL

-- ndfl.tax_years references shared.users
CONSTRAINT tax_years_user_fk FOREIGN KEY (user_id)
    REFERENCES shared.users (id) ON DELETE CASCADE
```

**Dependency order for migrations:**

```
shared  (no external deps)
  └── screenerx  (depends on shared.users)
        └── quantnova  (depends on shared.users + screenerx.symbols + screenerx.portfolios)
  └── ndfl  (depends on shared.users only)
```

This means migrations must always be run in the order: `shared → screenerx → quantnova`, and `shared → ndfl` independently.

---

## Multi-Tenancy Approach

finstack-db uses **schema-level namespace isolation** combined with **row-level tenant isolation** via a `tenant_id` column.

**Tenant ID propagation:**

The `tenant_id` UUID is set on creation and never updated. It flows through:

- `shared.users.tenant_id` — set at user registration
- `screenerx.portfolios.tenant_id` — inherited from the creating user
- All audit logs, billing records, and notifications carry `tenant_id` in their metadata JSONB

**RLS (Row-Level Security) enforcement:**

```sql
-- Enable RLS on users table
ALTER TABLE shared.users ENABLE ROW LEVEL SECURITY;

-- Application roles can only see rows for their tenant
CREATE POLICY tenant_isolation ON shared.users
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

The application layer sets the tenant context at the start of each request:

```sql
SET LOCAL app.current_tenant_id = '<tenant-uuid>';
```

**Service account roles:**

- `finstack_admin` — superuser equivalent, bypasses RLS (migrations, backfills)
- `screenerx_app` — CRUD on `screenerx.*`, SELECT on `shared.*`, RLS enforced
- `quantnova_app` — CRUD on `quantnova.*`, SELECT on `screenerx.symbols`, RLS enforced
- `ndfl_app` — CRUD on `ndfl.*`, SELECT on `shared.users`, RLS enforced
- `readonly` — SELECT on all schemas, used by analytics and reporting tools

---

## TimescaleDB Hypertable Strategy

18 tables are converted to TimescaleDB hypertables. The chunk interval is chosen based on write frequency and query range:

| Table | Schema | Time Column | Chunk Interval | Space Partitions | Reason |
|---|---|---|---|---|---|
| `market_data_ticks` | screenerx | `timestamp` | 1 day | 16 (symbol_id) | Highest write rate; 1-day chunks keep chunk count manageable; space partitions enable parallel scans by symbol |
| `order_books` | screenerx | `timestamp` | 1 day | 8 (symbol_id) | High write rate for L2 snapshots |
| `market_data_1m` | screenerx | `timestamp` | 7 days | — | Moderate rate; 7-day chunks balance compression overhead |
| `market_data_5m` | screenerx | `timestamp` | 14 days | — | Lower rate than 1m |
| `market_data_15m` | screenerx | `timestamp` | 30 days | — | Lower rate |
| `market_data_1h` | screenerx | `timestamp` | 90 days | — | Lower rate |
| `market_data_1d` | screenerx | `date` | 1 year | — | Low rate; daily candles only |
| `sentiment_data` | screenerx | `timestamp` | 7 days | — | NLP signal aggregation |
| `financial_ratios` | screenerx | `as_of_date` | 3 months | — | Daily ratio snapshots per symbol |
| `portfolio_snapshots` | screenerx | `snapshot_date` | 3 months | — | EOD NAV snapshots |
| `portfolio_performance` | screenerx | `date` | 3 months | — | Daily return metrics |
| `alert_events` | screenerx | `triggered_at` | 14 days | — | Alert trigger log |
| `kpi_metrics` | screenerx | `metric_date` | 1 month | — | Platform analytics |
| `user_activity` | screenerx | `created_at` | 7 days | — | Behavioural event log |
| `pnl_snapshots` | quantnova | `timestamp` | 1 day | — | Intraday P&L updates |
| `alpha_signals` | quantnova | `signal_date` | 1 month | — | Strategy signals |
| `feature_values` | quantnova | `as_of_date` | 3 months | — | ML feature history |
| `inference_logs` | quantnova | `predicted_at` | 7 days | — | ML prediction audit |
| `event_store` | quantnova | `occurred_at` | 7 days | — | Domain event log |

**Compression policy:** Chunks older than 7 days for tick/order-book tables, 30 days for OHLCV tables are compressed using TimescaleDB native compression (columnar, lz4). Expected compression ratio: 10–20x for tick data.

**Retention policy:** Tick data: 90 days. 1-minute OHLCV: 2 years. Daily OHLCV: indefinite. Inference logs: 1 year. User activity: 1 year.

**Continuous aggregates:**

- `cagg_market_data_5m` — 5-minute OHLCV from ticks, refreshed every 5 minutes with a 10-minute lag.
- `cagg_market_data_1h` — 1-hour OHLCV from 5m aggregate, refreshed every 1 hour.
- `cagg_daily_volume_profile` — Daily VWAP and volume profile per symbol, refreshed once at market close.

---

## Redis Caching Strategy

### screenerx domain

| Key Pattern | Type | TTL | Purpose |
|---|---|---|---|
| `market:price:{symbol_id}` | Hash | 300s (refresh on tick) | Latest traded price, OHLC, bid/ask |
| `market:orderbook:{symbol_id}:{side}` | Sorted Set | 60s | L2 order book — price as score |
| `market:candle:{symbol_id}:{timeframe}` | Hash | Matches timeframe | Current incomplete candle |
| `market:status:{exchange_code}` | Hash | 3600s | Exchange open/closed status |
| `screener:cache:{sha256(filters)}` | String (JSON) | 300s | Screener result deduplication |
| `screener:running:{user_id}:{screener_id}` | String | 30s | Execution lock (idempotency) |
| `watchlist:{user_id}:{watchlist_id}` | Sorted Set | None | Ordered watchlist items |
| `portfolio:nav:{portfolio_id}:{date}` | String | 86400s | End-of-day NAV |
| `portfolio:positions:{portfolio_id}` | Hash | 300s | Current positions with P&L |
| `alert:cooldown:{alert_id}` | String | cooldown_seconds | Alert rate-limiting |
| `rankings:gainers:{exchange}:{date}` | Sorted Set | 86400s | Top gainers by change_pct |
| `rankings:losers:{exchange}:{date}` | Sorted Set | 86400s | Top losers |
| `rankings:volume:{exchange}:{date}` | Sorted Set | 86400s | Top volume |

### shared domain

| Key Pattern | Type | TTL | Purpose |
|---|---|---|---|
| `session:{session_id}` | Hash | session_expires_at | Active JWT session data |
| `ratelimit:{user_id}:{endpoint}` | String (counter) | 60s | API rate limiting (sliding window) |
| `otp:{user_id}:{type}` | String | 300s | Email/SMS verification OTP |
| `api_key:{key_hash}` | String (user_id) | 3600s | API key lookup cache |

### quantnova domain

| Key Pattern | Type | TTL | Purpose |
|---|---|---|---|
| `order:state:{order_id}` | Hash | 86400s | Live order state (status, fills) |
| `position:{user_id}:{symbol_id}` | Hash | 300s | Current position for risk checks |
| `risk:{user_id}:daily_loss` | String | EOD | Running daily P&L for max-loss limit |

---

## Elasticsearch Indexing Strategy

### `stocks` index

Stores one document per instrument for fast autocomplete, full-text search, and faceted filtering.

**Analyzer configuration:**
- `ticker_analyzer` — lowercase + keyword tokenizer for exact-match ticker search (e.g. "RELIANCE", "TCS").
- `name_analyzer` — standard tokenizer with ngram filter (min 2, max 10) for prefix search as the user types.
- `edge_ngram_analyzer` — edge-ngram (1–15 chars) for autocomplete.

**Key fields:** `ticker`, `name`, `isin`, `sector`, `industry`, `exchange_code`, `market_cap_category`, `instrument_type`, `is_active`.

**Refresh policy:** Near-real-time (default 1s). Updated by a change-data-capture (CDC) process listening to `screenerx.symbols` and `screenerx.companies`.

### `news` index

One document per news article for full-text search and sentiment-tagged filtering.

**Key fields:** `headline`, `body_text`, `source`, `published_at`, `symbols` (array of tickers mentioned), `sentiment_label`, `sentiment_score`, `categories`.

**Refresh policy:** Updated by the news ingestion pipeline within 5 seconds of article ingest.

**Index lifecycle:** Monthly rollover at 50 GB or 30 million documents. Alias `news` always points to the current write index.

---

## Kafka Event Streaming Architecture

### Topics and schemas

| Topic | Event Schema | Producer | Consumers | Partitioning Key |
|---|---|---|---|---|
| `tick.raw` | `market_tick_event.json` | Market data feed adapter | TimescaleDB writer, Redis LTP updater, WebSocket gateway | `symbol_id` |
| `order.events` | `order_event.json` | Order management service | Risk engine, P&L calculator, portfolio updater | `user_id` |
| `execution.events` | `execution_event.json` | Broker adapter | Position updater, P&L calculator, audit writer | `order_id` |
| `signal.events` | `signal_event.json` | Strategy engine | Order router, alert trigger | `strategy_id` |
| `risk.events` | `risk_event.json` | Risk engine | Notification service, dashboard | `user_id` |
| `alert.events` | `alert_triggered_event.json` | Alert evaluator | Notification service, alert_events writer | `user_id` |
| `portfolio.events` | `portfolio_updated_event.json` | Portfolio service | Redis cache invalidator, analytics | `portfolio_id` |
| `tax.events` | `tax_event.json` | Capital gains calculator | NDFL service, filing preparer | `user_id` |
| `filing.events` | `filing_event.json` | NDFL service | Notification service, audit writer | `user_id` |
| `user.events` | `user_event.json` | Auth service | Notification service, Elasticsearch sync | `user_id` |
| `notification.events` | `notification_event.json` | Notification service | Push delivery, email delivery, SMS delivery | `user_id` |

### Schema Registry

All schemas are registered in Confluent Schema Registry (JSON Schema, draft-07). Compatibility mode: `BACKWARD` — consumers can read messages produced with the previous schema version.

### Consumer groups

- `timescaledb-writer` — writes ticks and events to PostgreSQL hypertables, parallelism = number of topic partitions.
- `redis-updater` — updates LTP hashes and pub/sub channels.
- `ws-gateway` — fans out ticks to WebSocket clients.
- `notification-dispatcher` — reads from `notification.events`, dispatches via push/email/SMS.
- `elasticsearch-sync` — syncs user and symbol changes to Elasticsearch.

### Retention

Kafka log retention: 7 days for all topics (configurable per topic). `tick.raw` compaction is disabled (event log, not state log).

---

## Security: RLS Policies and Schema Isolation

### Row-Level Security

RLS is enabled on all tables that contain user-owned or tenant-owned data:

```sql
ALTER TABLE shared.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE screenerx.portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE screenerx.portfolio_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quantnova.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE ndfl.tax_years ENABLE ROW LEVEL SECURITY;
-- ... and all other user-owned tables
```

RLS policies enforce that application roles can only read and write rows belonging to the current tenant:

```sql
CREATE POLICY tenant_isolation_policy ON shared.users
    AS PERMISSIVE FOR ALL
    TO screenerx_app
    USING (tenant_id = current_setting('app.current_tenant_id', TRUE)::UUID);
```

The `finstack_admin` role bypasses RLS (it has `BYPASSRLS` privilege) and is used only for migrations and data operations.

### Schema Isolation

- Application roles have `USAGE` on their own schema only, plus `shared`.
- `GRANT SELECT` on `screenerx.symbols` and `screenerx.portfolios` is explicitly given to `quantnova_app` for cross-schema FK lookups.
- No application role has `DROP`, `TRUNCATE`, or DDL privileges. Only `finstack_admin` can alter structure.

### Sensitive column handling

- `shared.users.password_hash` — bcrypt/argon2 hash, never returned in views. Application layer enforces no SELECT of this column.
- `shared.api_keys` — stores the SHA-256 hash of the key, never the plaintext. Lookup is hash-to-hash comparison.
- `shared.sessions.refresh_token_hash` — hashed, same pattern as API keys.
- `shared.oauth_accounts.access_token` — encrypted at rest using `pgcrypto` `encrypt()` with a key from the application environment.

---

## Scalability Considerations

### Read scalability

- **TimescaleDB** parallel chunk scans allow multi-core utilisation for time-range queries across large tick datasets.
- **Read replicas** — all reporting, analytics, and read-heavy API endpoints should be pointed to a streaming replica. The `readonly` role is designed for this.
- **Materialized views** (`mv_stock_daily_summary`, `mv_sector_performance`, `mv_portfolio_summary`, `mv_top_movers`) are refreshed on a schedule and serve dashboard queries without hitting raw tables.
- **Redis** absorbs the majority of price read traffic, keeping PostgreSQL free for transactional writes.

### Write scalability

- **TimescaleDB** hypertables use background workers to compress old chunks and run continuous aggregate refreshes without blocking ingestion.
- **Kafka** partitioning by `symbol_id` / `user_id` allows horizontal scaling of consumers independently of the broker count.
- **Batch inserts** — the TimescaleDB writer consumer uses `COPY` for bulk tick ingestion, achieving 100 000+ rows/second throughput on a single node.

### Vertical scaling boundaries

- PostgreSQL connection limit: configure `pgBouncer` (transaction mode) in front of PostgreSQL to multiplex many application connections onto a small pool.
- Redis memory: configured at 512 MB `maxmemory` with `allkeys-lru` eviction. Scale vertically or switch to Redis Cluster if the LTP + session footprint grows beyond 2 GB.
- Elasticsearch heap: 1 GB JVM heap configured in docker-compose. Increase to 4–8 GB for production with 1M+ documents.

### Future sharding path

If a single PostgreSQL instance becomes a bottleneck:

1. **Tick data** — migrate `market_data_ticks` to a dedicated TimescaleDB instance or Timescale Cloud. All other schemas remain on the primary.
2. **ML feature store** — `feature_values` and `inference_logs` are good candidates for an independent TimescaleDB instance as ML workloads grow.
3. **NDFL** — entirely separate database if compliance isolation is required by regulation.

The schema-per-project design makes this migration path tractable: foreign key references become application-level lookups, and each schema has a clean migration file that can be replayed on a new database.
