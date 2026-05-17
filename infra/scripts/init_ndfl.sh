#!/bin/bash
# ============================================================
# init_ndfl.sh — Initialize ndfl schema (tax & compliance)
# Requires shared schema to already exist.
# Usage: DATABASE_URL=postgres://... ./infra/scripts/init_ndfl.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATABASE_URL="${DATABASE_URL:-postgres://postgres:postgres@localhost:5432/finstack}"

echo "[ndfl] Running migrations..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  --single-transaction \
  -f "$DB_ROOT/ndfl/postgres/migrations/001_create_schema.sql"
echo "[ndfl] Done."
