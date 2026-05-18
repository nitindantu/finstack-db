## Summary

<!-- What schema change does this PR introduce? Why? 2-3 sentences. -->

## Type of change

- [ ] New table(s)
- [ ] New columns on existing table(s)
- [ ] New index(es)
- [ ] New enum type / enum value
- [ ] Seed data only
- [ ] Documentation only
- [ ] Bug fix (corrects existing DDL/DML)

## SQL files changed

<!-- List every .sql file added or modified -->

-
-

## Checklist

- [ ] File names follow `NNN_name.sql` (DDL) or `seed_NNN_name.sql` (DML) convention
- [ ] Migration is **additive only** — no `DROP`, `TRUNCATE`, or destructive `ALTER`
- [ ] All new tables have `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
- [ ] All new tables have `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` and `updated_at`
- [ ] Indexes added for all foreign keys and common filter columns
- [ ] Seed scripts use `INSERT ... ON CONFLICT DO NOTHING` with fixed UUIDs
- [ ] Prisma schema in ScreenerX updated to reflect new tables (if applicable)
- [ ] `docs/SCHEMA_REFERENCE.md` updated
- [ ] `docs/RELEASE_NOTES.md` updated with new table/column entries
- [ ] `docs/ER_DIAGRAMS.md` updated with new Mermaid entities (if applicable)

## Rollback plan

<!-- How do we undo this if it causes issues in production? -->

- [ ] Drop the new table(s): `DROP TABLE IF EXISTS <schema>.<table> CASCADE;`
- [ ] PITR restore to snapshot taken before deployment
- [ ] Other: <!-- describe -->
