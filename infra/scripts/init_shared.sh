#!/bin/bash
# ============================================================
# init_shared.sh — Initialize shared schema (users, auth, billing)
# Usage: DATABASE_URL=postgres://... ./infra/scripts/init_shared.sh
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATABASE_URL="${DATABASE_URL:-postgres://postgres:postgres@localhost:5432/finstack}"

echo "[shared] Running migrations..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  --single-transaction \
  -f "$DB_ROOT/shared/postgres/migrations/001_create_schema.sql"
echo "[shared] Done."
