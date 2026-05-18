## [1.3.0](https://github.com/nitindantu/finstack-db/compare/v1.2.0...v1.3.0) (2026-05-18)


### Features

* **screenerx:** add AI copilot sessions and messages tables (083, 084)
* **screenerx:** add risk profiles table with SEBI risk-o-meter support (085)
* **screenerx:** add financial goals table with Monte Carlo result storage (086)
* **screenerx:** add retirement plans table with corpus planning fields (087)
* **screenerx:** add portfolio analyses table with Sharpe/Sortino metrics (088)
* **screenerx:** add AI investment recommendations table with SEBI compliance flags (089)
* **screenerx:** add market intelligence summaries table with 2hr cache TTL (090)
* **screenerx:** add financial health scores table with composite grade (091)
* **shared:** add advisor_clients table for SEBI RIA workflows (014)
* **shared:** add advisor_approvals table for human-in-loop AI recommendation review (015)

---

## [1.2.0](https://github.com/nitindantu/finstack-db/compare/v1.1.0...v1.2.0) (2026-05-17)


### Features

* **ci:** add validate.yml with SQL lint, Neon branch dry-run, and schema diff PR comment
* **ci:** add migrate-staging.yml for auto-deploy to Neon staging on main push
* **ci:** add migrate-production.yml with manual approval gate for production migrations
* **ci:** add release.yml with semantic-release configuration
* **docs:** add CONTRIBUTING.md with conventional commits and migration rules
* **docs:** add pull_request_template.md with SQL-specific checklist

---

## [1.1.0](https://github.com/nitindantu/finstack-db/compare/v1.0.2...v1.1.0) (2026-05-18)


### Features

* **schema:** add AI financial platform tables (083-091, 014-015) ([65480c9](https://github.com/nitindantu/finstack-db/commit/65480c9da75e83978545bfb934d243cc72a2f45b))
* **screenerx:** add market_indices table with sparkline support (080)
* **screenerx:** add fii_dii_activity table with generated net columns (081)
* **screenerx:** add ipos table with GMP and subscription tracking (082)
* **seed:** add 15 market index snapshots (seed_010)
* **seed:** add 10 days FII/DII activity (seed_011)
* **seed:** add 7 IPO records (seed_012)
* **seed:** add 10 economic calendar events (seed_013)

---

## [1.0.2](https://github.com/nitindantu/finstack-db/compare/v1.0.1...v1.0.2) (2026-05-18)


### Bug Fixes

* **ci:** skip SQL checks and Neon dry-run for Dependabot PRs ([075677e](https://github.com/nitindantu/finstack-db/commit/075677e691bae93f47bf4dd82c4f06a27150beee))

## [1.0.1](https://github.com/nitindantu/finstack-db/compare/v1.0.0...v1.0.1) (2026-05-18)


### Bug Fixes

* **ci:** rewrite Neon branch creation to fix Python quoting error ([d073e32](https://github.com/nitindantu/finstack-db/commit/d073e32f748d2bec1e681618a36bd22f84077827))

# 1.0.0 (2026-05-18)


### Features

* add market_indices, fii_dii_activity, ipos tables + seed data ([8f9970e](https://github.com/nitindantu/finstack-db/commit/8f9970eddf91c75a505096c1bd0fc96fdfb3aebf))
