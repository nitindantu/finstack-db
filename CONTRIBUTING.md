# Contributing to finstack-db

## Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/). This drives semantic-release version bumps and the auto-generated CHANGELOG.

### Format

```
<type>(<scope>): <short description>
```

### Types

| Type | Version bump | Use for |
|------|-------------|---------|
| `feat` | minor | New table, column, index, or seed data |
| `fix` | patch | Correcting a DDL bug or broken seed |
| `docs` | none | SCHEMA_REFERENCE, ER_DIAGRAMS, RELEASE_NOTES |
| `chore` | none | CI config, file renames |
| `ci` | none | GitHub Actions workflow changes |
| `BREAKING CHANGE` footer | major | Destructive schema change (rare, staging only) |

### Scopes

Use one of: `shared`, `screenerx`, `quantnova`, `ndfl`, `timescaledb`, `redis`, `kafka`, `elasticsearch`, `docs`, `ci`, `seed`, `ai`

### Examples

```bash
feat(screenerx): add option_chains table for F&O data
feat(seed): add 10-day FII/DII equity seed data
fix(screenerx): correct fii_net generated column expression
docs(screenerx): update ER diagram with market_indices entity
ci: add Neon branch dry-run to validate workflow
feat(ndfl)!: restructure capital_gains to support cost indexation

BREAKING CHANGE: column indexed_cost replaces cost_of_acquisition
```

## File Naming Conventions

| File type | Convention | Example |
|-----------|-----------|---------|
| DDL | `NNN_table_name.sql` | `083_option_chains.sql` |
| Seed data | `seed_NNN_description.sql` | `seed_014_option_data.sql` |
| Migration bundle | `001_create_schema.sql` | (one per domain) |

## Migration Rules

1. **Additive only in production** — `CREATE TABLE`, `ADD COLUMN` (nullable or with DEFAULT), `CREATE INDEX CONCURRENTLY`
2. Never `DROP COLUMN`, `DROP TABLE`, or change column types without a major version bump and a coordinated ScreenerX backend deployment
3. All new tables must have:
   - `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
   - `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
   - `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
4. All seed scripts must use `INSERT ... ON CONFLICT DO NOTHING` with fixed UUIDs

## Schema Dependency Order

```
shared → screenerx → quantnova
shared → ndfl
```

Always apply migrations in this order. Never run `quantnova` before `screenerx`.

## Branch Strategy

```
main        → triggers production migration on release tag
develop     → triggers staging migration on push
feature/*   → open PRs against develop
```

## PR Checklist

See `.github/pull_request_template.md` — fill it out completely before requesting review.
