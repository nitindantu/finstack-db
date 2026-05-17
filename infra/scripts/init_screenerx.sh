#!/bin/bash
# ============================================================
# init_screenerx.sh — Initialize screenerx schema
# Requires shared schema to already exist.
# Usage: DATABASE_URL=postgres://... ./infra/scripts/init_screenerx.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATABASE_URL="${DATABASE_URL:-postgres://postgres:postgres@localhost:5432/finstack}"

echo "[screenerx] Running migrations..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  --single-transaction \
  -f "$DB_ROOT/screenerx/postgres/migrations/001_create_schema.sql"
echo "[screenerx] Done."
