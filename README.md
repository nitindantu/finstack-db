# finstack-db

Database schemas, migrations, and infrastructure configuration for the **Finstack** suite of financial applications.

---

## Project Domains

| Domain | Description | PostgreSQL Schema |
|--------|-------------|-------------------|
| `shared` | Cross-project: users, auth, billing, notifications | `shared` |
| `screenerx` | Stock screener & portfolio platform | `screenerx` |
| `quantnova` | Quantitative trading & ML/AI platform | `quantnova` |
| `ndfl` | Tax & compliance (ITR filing, capital gains) | `ndfl` |

---

## Repository Structure

```
database/
├── shared/                        # Cross-project tables
│   ├── postgres/
│   │   ├── ddl/                   # users, roles, sessions, billing, notifications (000-013)
│   │   ├── dml/                   # seed_001_users.sql
│   │   ├── indexes/
│   │   ├── triggers/
│   │   ├── functions/
│   │   └── migrations/            # 001_create_schema.sql
│   ├── redis/
│   │   └── key_schemas.md
│   └── kafka/
│       └── schemas/               # user_event.json, notification_event.json
│
├── screenerx/                     # Stock screener platform
│   ├── postgres/
│   │   ├── ddl/                   # exchanges, symbols, market_data, fundamentals,
│   │   │                          # screener, portfolio, alerts, analytics (014-050, 073-079)
│   │   ├── dml/                   # seed_002 through seed_007
│   │   ├── indexes/
│   │   ├── triggers/
│   │   ├── views/
│   │   ├── materialized_views/
│   │   ├── functions/
│   │   └── migrations/            # 001_create_schema.sql
│   ├── timescaledb/               # Hypertables, compression, retention, caggs
│   ├── redis/
│   │   └── key_schemas.md
│   ├── elasticsearch/
│   │   └── mappings/              # stocks_mapping.json, news_mapping.json
│   └── kafka/
│       └── schemas/               # market_tick_event.json, alert_triggered_event.json,
│                                  # portfolio_updated_event.json
│
├── quantnova/                     # Quantitative trading platform
│   ├── postgres/
│   │   ├── ddl/                   # brokers, orders, executions, strategies,
│   │   │                          # backtests, ML models, feature store (051-072, 075)
│   │   ├── dml/                   # seed_008_trading.sql
│   │   ├── indexes/
│   │   ├── triggers/
│   │   └── migrations/            # 001_create_schema.sql
│   ├── timescaledb/
│   ├── redis/
│   │   └── key_schemas.md
│   └── kafka/
│       └── schemas/               # order_event.json, signal_event.json,
│                                  # execution_event.json, risk_event.json
│
├── ndfl/                          # Tax & compliance platform
│   ├── postgres/
│   │   ├── ddl/                   # tax_years, income_sources, capital_gains,
│   │   │                          # tds_records, form26as, tax_computations,
│   │   │                          # tax_payments, tax_documents (001-008)
│   │   ├── dml/
│   │   ├── indexes/
│   │   └── migrations/            # 001_create_schema.sql
│   └── kafka/
│       └── schemas/               # tax_event.json, filing_event.json
│
└── infra/
    ├── docker-compose.yml         # postgres+timescaledb, redis, elasticsearch, kafka
    ├── scripts/
    │   ├── init_shared.sh
    │   ├── init_screenerx.sh
    │   ├── init_quantnova.sh
    │   ├── init_ndfl.sh
    │   └── init_all.sh
    └── README.md (this file)
```

---

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| PostgreSQL | 16 | Primary relational database |
| TimescaleDB | latest | Time-series extension for market tick data |
| Redis | 7 | Caching, sessions, pub/sub, rate limiting |
| Elasticsearch | 8.13 | Full-text search (stocks, news) |
| Apache Kafka | 3.6 (CP 7.6) | Event streaming and domain events |
| Confluent Schema Registry | 7.6 | Kafka schema management |

---

## Running Migrations

### Prerequisites

```bash
# Start all infrastructure
cd infra
docker compose up -d

# Wait for postgres to be ready
docker compose exec postgres pg_isready
```

### Initialize All Schemas (recommended for first-time setup)

```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"
./infra/scripts/init_all.sh
```

### Initialize Individual Domains

```bash
# Always run shared first
./infra/scripts/init_shared.sh

# Then run project-specific schemas (order matters for cross-schema FKs)
./infra/scripts/init_screenerx.sh
./infra/scripts/init_quantnova.sh
./infra/scripts/init_ndfl.sh
```

### Schema Dependency Order

```
shared  →  screenerx  →  quantnova
        →  ndfl
```

`quantnova` tables reference `screenerx.symbols` and `screenerx.portfolios`, so screenerx must be initialized before quantnova.

---

## Schema Naming Conventions

All tables are schema-qualified:

- `shared.users`, `shared.sessions`, `shared.billing_transactions`
- `screenerx.symbols`, `screenerx.portfolios`, `screenerx.alerts`
- `quantnova.orders`, `quantnova.strategies`, `quantnova.ml_models`
- `ndfl.tax_years`, `ndfl.capital_gains`, `ndfl.tax_computations`

Cross-schema foreign keys are fully qualified:
```sql
CONSTRAINT orders_symbol_fk FOREIGN KEY (symbol_id)
  REFERENCES screenerx.symbols (id) ON DELETE RESTRICT
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `postgres://postgres:postgres@localhost:5432/finstack` | PostgreSQL connection string |
| `POSTGRES_USER` | `postgres` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL password |
| `POSTGRES_DB` | `finstack` | Database name |
| `REDIS_PASSWORD` | `redispass` | Redis auth password |
| `KAFKA_PORT` | `9092` | Kafka broker port |
| `ELASTICSEARCH_PORT` | `9200` | Elasticsearch HTTP port |

---

## Key Design Decisions

- **PostgreSQL schemas as namespace boundaries** — each project domain lives in its own schema, enabling fine-grained permission grants and logical separation without multiple databases.
- **TimescaleDB for market data** — `market_data_ticks` and `market_data_ohlcv` are hypertables partitioned by time, with automatic compression and retention policies.
- **Event sourcing in quantnova** — `event_store` table captures all domain events for audit and replay.
- **Redis for hot data** — prices, sessions, screener caches, and order state are cached in Redis to keep PostgreSQL load manageable.
- **JSON Schema for Kafka** — all Kafka event schemas are defined in JSON Schema draft-07, compatible with Confluent Schema Registry.
