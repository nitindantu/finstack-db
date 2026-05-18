# Migration Guide

Step-by-step instructions for initialising and managing the finstack-db schemas across all supported environments.

## Table of Contents

- [Automated Migrations via CI/CD](#automated-migrations-via-cicd)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Running on Neon (Cloud PostgreSQL)](#running-on-neon-cloud-postgresql)
- [Running Locally with Docker](#running-locally-with-docker)
- [Running Individual Domains](#running-individual-domains)
- [Applying TimescaleDB Configuration](#applying-timescaledb-configuration)
- [Loading Seed Data](#loading-seed-data)
- [Rollback Strategy](#rollback-strategy)
- [Troubleshooting Common Errors](#troubleshooting-common-errors)

---

## Automated Migrations via CI/CD

As of **v1.2.0**, migrations run automatically through GitHub Actions. You only need to run `psql` manually for local development or one-off tasks.

| Scenario | How migrations run |
|----------|--------------------|
| Pull request opened | `validate.yml` spins an ephemeral Neon branch, runs every migration, verifies table counts, posts schema diff comment, then deletes the branch |
| Merge to `main` (SQL files changed) | `migrate-staging.yml` applies all migrations + seed data to Neon **staging** automatically |
| Semver tag pushed (`v*.*.*`) | `migrate-production.yml` applies all migrations to Neon **production** after a manual approval in GitHub Environments |

**Required GitHub Secrets** (Settings → Secrets → Actions):

| Secret | Environment |
|--------|-------------|
| `STAGING_DATABASE_URL` | Neon staging connection string |
| `PRODUCTION_DATABASE_URL` | Neon production connection string |
| `NEON_API_KEY` | Neon API key (for PR dry-run branch creation) |
| `NEON_PROJECT_ID` | Neon project ID |
| `STAGING_DB_PASSWORD` | Neon staging DB password (for dry-run branch) |

**To add a new migration and have it deploy automatically:**
1. Create your `NNN_table_name.sql` file in the correct domain DDL directory
2. Open a PR → CI dry-runs it on a real Neon branch
3. Merge to `main` → auto-deploys to staging
4. Push a semver tag → approve in GitHub → deploys to production

---

## Prerequisites

### Required tools

| Tool | Minimum Version | Purpose |
|---|---|---|
| `psql` | 14+ | PostgreSQL CLI client for running migration scripts |
| Docker | 24+ | Local infrastructure (PostgreSQL + TimescaleDB + Redis + Kafka + Elasticsearch) |
| Docker Compose | 2.x (Compose V2) | Orchestrating the local stack |
| Bash | 3.2+ | Running init shell scripts |

**Install psql (macOS):**

```bash
brew install libpq
echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Install psql (Ubuntu / Debian):**

```bash
sudo apt-get install -y postgresql-client
```

**Install Docker Desktop:**

Download from [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

### Verify tool versions

```bash
psql --version
docker --version
docker compose version
```

---

## Environment Setup

### Create a `.env` file

Copy the example values and adjust for your environment:

```bash
cat > /path/to/database/infra/.env << 'EOF'
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=finstack
POSTGRES_PORT=5432

# Redis
REDIS_PASSWORD=redispass
REDIS_PORT=6379

# Elasticsearch
ELASTICSEARCH_PORT=9200

# Kafka
KAFKA_PORT=9092
ZOOKEEPER_PORT=2181
SCHEMA_REGISTRY_PORT=8081
EOF
```

### Export the DATABASE_URL

The migration scripts use the `DATABASE_URL` environment variable:

```bash
# Local Docker
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"

# Neon (cloud)
export DATABASE_URL="postgresql://<user>:<password>@<host>.neon.tech/finstack?sslmode=require"
```

---

## Running on Neon (Cloud PostgreSQL)

Neon supports all PostgreSQL 16 features. TimescaleDB-specific commands (`create_hypertable`, continuous aggregates) are **not available** on Neon — skip those files.

### Step 1: Obtain your Neon connection string

From the Neon Console → Project → Connection Details:

```
postgresql://neondb_owner:<password>@ep-xxx-yyy.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Step 2: Export the connection string

```bash
export DATABASE_URL="postgresql://neondb_owner:<password>@ep-xxx-yyy.us-east-1.aws.neon.tech/neondb?sslmode=require"
```

### Step 3: Run migrations in order

```bash
DB_ROOT="/path/to/finstack-db"

# 1. Shared schema (extensions, enums, tables, functions, triggers, indexes)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f "$DB_ROOT/shared/postgres/migrations/001_create_schema.sql"

# 2. ScreenerX schema (v1.0.0 — 47 tables)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f "$DB_ROOT/screenerx/postgres/migrations/001_create_schema.sql"

# 3. QuantNova schema
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f "$DB_ROOT/quantnova/postgres/migrations/001_create_schema.sql"

# 4. NDFL schema
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f "$DB_ROOT/ndfl/postgres/migrations/001_create_schema.sql"

# 5. ScreenerX v1.1.0 dashboard tables (market_indices, fii_dii_activity, ipos)
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/ddl/080_market_indices.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/ddl/081_fii_dii_activity.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/ddl/082_ipos.sql"
```

### Step 4: Load seed data

```bash
# Core seed data (v1.0.0)
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_002_exchanges.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_003_symbols.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_004_companies.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_005_market_data.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_006_portfolios.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_007_screeners.sql"

# Dashboard seed data (v1.1.0)
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_010_market_indices.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_011_fii_dii.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_012_ipos.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_013_economic_events.sql"
```

### Step 4: Load seed data (optional)

```bash
psql "$DATABASE_URL" -f "$DB_ROOT/shared/postgres/dml/seed_001_users.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_002_exchanges.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_003_symbols.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_004_companies.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_005_market_data.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_006_portfolios.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/screenerx/postgres/dml/seed_007_screeners.sql"
psql "$DATABASE_URL" -f "$DB_ROOT/quantnova/postgres/dml/seed_008_trading.sql"
```

### Step 5: Verify

```bash
psql "$DATABASE_URL" -c "SELECT table_schema, count(*) AS tables FROM information_schema.tables WHERE table_schema IN ('shared','screenerx','quantnova','ndfl') GROUP BY 1 ORDER BY 1;"
```

Expected output:

```
 table_schema | tables
--------------+--------
 ndfl         |      8
 quantnova    |     23
 screenerx    |     47
 shared       |     13
```

---

## Running Locally with Docker

The Docker Compose file starts PostgreSQL + TimescaleDB, Redis, Elasticsearch, Kafka, Zookeeper, and Confluent Schema Registry.

### Step 1: Start the full stack

```bash
cd "/path/to/database/infra"
docker compose up -d
```

### Step 2: Wait for services to become healthy

```bash
# PostgreSQL ready
docker compose exec postgres pg_isready -U postgres -d finstack

# Redis ready
docker compose exec redis redis-cli -a redispass ping

# Elasticsearch ready (may take 30-60 seconds)
curl -s http://localhost:9200/_cluster/health | python3 -m json.tool
```

### Step 3: Run all migrations

```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"
cd "/path/to/database"
./infra/scripts/init_all.sh
```

The `init_all.sh` script runs all four migrations in dependency order and exits on any error.

### Step 4: Apply TimescaleDB configuration

After the main migrations, apply the TimescaleDB hypertable declarations and policies:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/hypertables/create_hypertables.sql

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_5m.sql

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_1h.sql

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/continuous_aggregates/cagg_daily_volume_profile.sql

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/compression/compression_policies.sql

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f screenerx/timescaledb/retention/retention_policies.sql
```

### Step 5: Load seed data

```bash
./infra/scripts/init_shared.sh   # includes seed_001
# Seed scripts are included inside the domain migration files
# or run individually:
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_002_exchanges.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_003_symbols.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_004_companies.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_005_market_data.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_006_portfolios.sql
psql "$DATABASE_URL" -f screenerx/postgres/dml/seed_007_screeners.sql
psql "$DATABASE_URL" -f quantnova/postgres/dml/seed_008_trading.sql
```

### Stopping and cleaning up

```bash
# Stop containers (preserves volumes)
docker compose down

# Stop and destroy all data volumes
docker compose down -v
```

---

## Running Individual Domains

All `init_*.sh` scripts accept the `DATABASE_URL` environment variable.

```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/finstack"
DB_ROOT="/path/to/database"

# Always run shared first
./infra/scripts/init_shared.sh

# Then screenerx (depends on shared.users)
./infra/scripts/init_screenerx.sh

# Then quantnova (depends on shared.users + screenerx.symbols + screenerx.portfolios)
./infra/scripts/init_quantnova.sh

# ndfl only depends on shared.users — can run in parallel with screenerx/quantnova
./infra/scripts/init_ndfl.sh
```

### Schema dependency order

```
shared
  ├── screenerx   (references shared.users)
  │     └── quantnova  (references screenerx.symbols, screenerx.portfolios)
  └── ndfl        (references shared.users)
```

**If you attempt to run quantnova before screenerx**, the migration will fail with:

```
ERROR:  relation "screenerx.symbols" does not exist
```

---

## Applying TimescaleDB Configuration

TimescaleDB configuration is separated from the main DDL migrations because it requires the TimescaleDB extension to be installed and `CREATE EXTENSION IF NOT EXISTS timescaledb;` to have been run (included in `shared/postgres/ddl/000_extensions.sql`).

These scripts are idempotent (all use `if_not_exists => TRUE`):

```bash
# Convert tables to hypertables
psql "$DATABASE_URL" -f screenerx/timescaledb/hypertables/create_hypertables.sql

# Create continuous aggregates
psql "$DATABASE_URL" -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_5m.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/continuous_aggregates/cagg_market_data_1h.sql
psql "$DATABASE_URL" -f screenerx/timescaledb/continuous_aggregates/cagg_daily_volume_profile.sql

# Enable compression
psql "$DATABASE_URL" -f screenerx/timescaledb/compression/compression_policies.sql

# Set retention
psql "$DATABASE_URL" -f screenerx/timescaledb/retention/retention_policies.sql
```

**To check hypertable status:**

```sql
SELECT hypertable_name, num_chunks, compression_enabled
FROM timescaledb_information.hypertables
ORDER BY hypertable_name;
```

---

## Loading Seed Data

Seed scripts are fully idempotent. They use `INSERT ... ON CONFLICT DO NOTHING` with fixed UUIDs and can be safely re-run against an existing database.

**Load order** (seed data has FK dependencies):

```
seed_001_users          → shared.users
seed_002_exchanges      → screenerx.exchanges
seed_003_symbols        → screenerx.symbols (depends on exchanges)
seed_004_companies      → screenerx.companies (depends on symbols)
seed_005_market_data    → screenerx.market_data_ohlcv (depends on symbols)
seed_006_portfolios     → screenerx.portfolios, portfolio_positions (depends on users + symbols)
seed_007_screeners      → screenerx.saved_screeners, watchlists (depends on users + symbols)
seed_008_trading        → quantnova.brokers, strategies (depends on users)
```

**To verify seed data was loaded:**

```sql
SELECT 'users'     AS entity, count(*) FROM shared.users
UNION ALL
SELECT 'exchanges' AS entity, count(*) FROM screenerx.exchanges
UNION ALL
SELECT 'symbols'   AS entity, count(*) FROM screenerx.symbols
UNION ALL
SELECT 'companies' AS entity, count(*) FROM screenerx.companies
UNION ALL
SELECT 'ohlcv_1d'  AS entity, count(*) FROM screenerx.market_data_1d
UNION ALL
SELECT 'portfolios' AS entity, count(*) FROM screenerx.portfolios
UNION ALL
SELECT 'brokers'   AS entity, count(*) FROM quantnova.brokers;
```

---

## Rollback Strategy

There is no automated rollback. The recommended strategy is:

### Option A: Drop and recreate schemas

This destroys all data in the affected schema and recreates from scratch. Suitable for development and staging only.

```sql
-- WARNING: This drops all data in the schema
DROP SCHEMA screenerx CASCADE;
```

Then re-run the migration:

```bash
psql "$DATABASE_URL" -f screenerx/postgres/migrations/001_create_schema.sql
```

### Option B: Point-in-time restore (production)

For production environments on Neon or a managed PostgreSQL service, use the platform's PITR (Point-In-Time Recovery) feature to restore the database to a snapshot taken before the migration was applied.

**Neon PITR:** Dashboard → Project → Restore → Select a timestamp before the migration.

**Self-hosted PostgreSQL PITR:**

```bash
# Before running a migration, take a base backup
pg_basebackup -h localhost -U postgres -D /var/backups/finstack-$(date +%Y%m%d-%H%M%S) -Ft -z

# Restore from backup if needed
# Stop PostgreSQL, restore data directory, configure recovery.conf, start
```

### Option C: Additive-only changes (recommended for production)

All schema changes after v1.0.0 should be **additive only**:
- `ADD COLUMN` (with a default or nullable)
- `CREATE TABLE`
- `CREATE INDEX CONCURRENTLY`
- New enum values (append only)

Never `DROP COLUMN`, `ALTER COLUMN TYPE`, or `DROP TABLE` in a migration applied to a live database without a coordinated deployment and data backfill plan.

---

## Troubleshooting Common Errors

### `ERROR: role "postgres" does not exist`

The PostgreSQL user specified in `DATABASE_URL` does not exist.

**Fix:**

```bash
# Check what users exist
psql "postgres://localhost:5432/postgres" -c "\du"

# Create the user
psql "postgres://localhost:5432/postgres" -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';"
```

---

### `ERROR: database "finstack" does not exist`

The target database has not been created.

**Fix:**

```bash
psql "postgres://postgres:postgres@localhost:5432/postgres" -c "CREATE DATABASE finstack;"
```

Or, if using Docker Compose, ensure `POSTGRES_DB=finstack` is set in the environment and the container was started fresh (not resumed from a volume with a different DB name).

---

### `ERROR: extension "timescaledb" is not available`

The TimescaleDB extension is not installed in the PostgreSQL instance.

**Fix 1:** Use the TimescaleDB Docker image (already configured in docker-compose.yml):

```yaml
image: timescale/timescaledb:latest-pg16
```

**Fix 2:** If running on plain PostgreSQL 16, skip the TimescaleDB-specific scripts:

```bash
# Skip: screenerx/timescaledb/ (all files)
# Run only the core migration
psql "$DATABASE_URL" -f screenerx/postgres/migrations/001_create_schema.sql
```

---

### `ERROR: relation "screenerx.symbols" does not exist`

You ran `init_quantnova.sh` before `init_screenerx.sh`.

**Fix:** Run schemas in dependency order:

```bash
./infra/scripts/init_shared.sh
./infra/scripts/init_screenerx.sh
./infra/scripts/init_quantnova.sh
```

---

### `ERROR: type "user_status" does not exist`

The `shared/postgres/ddl/000_enums.sql` file was not run before the table DDL.

**Fix:** The `migrations/001_create_schema.sql` files include all dependencies in order. If you ran individual DDL files out of order, run the full migration file instead:

```bash
psql "$DATABASE_URL" -f shared/postgres/migrations/001_create_schema.sql
```

---

### `ERROR: duplicate key value violates unique constraint`

You ran a seed script on a database that already has seed data.

**Fix:** All seed scripts use `ON CONFLICT DO NOTHING`. If you see this error, a seed script may not be using the standard pattern. Check the specific seed file and add the conflict clause:

```sql
INSERT INTO shared.users (...) VALUES (...)
ON CONFLICT (id) DO NOTHING;
```

---

### `ERROR: SSL connection required`

You are connecting to Neon without `sslmode=require`.

**Fix:** Append `?sslmode=require` to your DATABASE_URL:

```bash
export DATABASE_URL="postgresql://user:pass@host.neon.tech/dbname?sslmode=require"
```

---

### `FATAL: remaining connection slots are reserved for non-replication superuser connections`

PostgreSQL has hit its `max_connections` limit.

**Fix:** Use PgBouncer in transaction pooling mode, or increase `max_connections` in `postgresql.conf` (requires a restart):

```sql
-- Check current connections
SELECT count(*), state FROM pg_stat_activity GROUP BY state;

-- On Docker, increase max_connections
docker exec finstack_postgres psql -U postgres -c "ALTER SYSTEM SET max_connections = 200;"
docker restart finstack_postgres
```

---

### Docker Compose: `port is already allocated`

Another process is using port 5432 (or 6379, 9200, 9092).

**Fix:** Either stop the conflicting service, or change the port mapping in docker-compose.yml or your `.env` file:

```bash
# .env
POSTGRES_PORT=5433
REDIS_PORT=6380
```

Then update your DATABASE_URL accordingly.

---

### `psql: error: connection to server ... failed: Connection refused`

PostgreSQL is not yet ready. The Docker container may still be starting.

**Fix:**

```bash
# Wait for readiness
until docker compose exec postgres pg_isready -U postgres -d finstack; do
  echo "Waiting for postgres..."
  sleep 2
done
echo "PostgreSQL is ready"
```
