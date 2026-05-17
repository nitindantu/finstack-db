#!/bin/bash
# ============================================================
# init_all.sh — Initialize all schemas in dependency order
# Usage: DATABASE_URL=postgres://... ./infra/scripts/init_all.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATABASE_URL="${DATABASE_URL:-postgres://postgres:postgres@localhost:5432/finstack}"

echo "=== Finstack DB: Full Schema Initialization ==="
echo "Target: $DATABASE_URL"
echo ""

# 1. Shared (must be first — all other schemas depend on it)
echo "Step 1/4: shared"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction \
  -f "$DB_ROOT/shared/postgres/migrations/001_create_schema.sql"
echo "  [OK] shared"

# 2. ScreenerX (depends on shared)
echo "Step 2/4: screenerx"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction \
  -f "$DB_ROOT/screenerx/postgres/migrations/001_create_schema.sql"
echo "  [OK] screenerx"

# 3. QuantNova (depends on shared + screenerx for symbol/portfolio refs)
echo "Step 3/4: quantnova"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction \
  -f "$DB_ROOT/quantnova/postgres/migrations/001_create_schema.sql"
echo "  [OK] quantnova"

# 4. NDFL (depends on shared only)
echo "Step 4/4: ndfl"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction \
  -f "$DB_ROOT/ndfl/postgres/migrations/001_create_schema.sql"
echo "  [OK] ndfl"

echo ""
echo "=== All schemas initialized successfully ==="
