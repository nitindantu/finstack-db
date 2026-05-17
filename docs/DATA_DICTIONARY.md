# Data Dictionary

Complete reference for all enum types, standard column conventions, naming conventions, and data type decisions used across finstack-db.

## Table of Contents

- [Enum Types (35 total)](#enum-types)
- [Standard Column Conventions](#standard-column-conventions)
- [Naming Conventions](#naming-conventions)
- [Data Type Decisions](#data-type-decisions)

---

## Enum Types

All enums (except `ndfl`-specific types) are defined globally in `shared/postgres/ddl/000_enums.sql` and are available in all schemas. Each `CREATE TYPE` is wrapped in a `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$;` block for idempotency.

The `ndfl` schema defines two additional schema-prefixed enum types locally in `ndfl/postgres/ddl/001_tax_years.sql`.

---

### User & Auth Domain

#### `user_status`

Tracks the lifecycle state of a user account.

| Value | Description |
|---|---|
| `active` | Account is fully functional and can log in |
| `inactive` | Account has been voluntarily deactivated by the user |
| `suspended` | Account suspended by an admin (terms violation, security concern) |
| `deleted` | Soft-deleted; row retained for audit but user cannot log in |

**Used in:** `shared.users.status`

---

#### `plan_type`

Subscription tier classification.

| Value | Description |
|---|---|
| `free` | Free tier with basic feature access |
| `basic` | Entry-level paid plan with standard screener and portfolio features |
| `premium` | Full-featured plan including alerts, advanced screener, and portfolio analytics |
| `enterprise` | Custom plan for institutional clients with API access and dedicated support |

**Used in:** `shared.users.plan_type`, `shared.subscriptions.plan_type`

---

#### `subscription_status`

Maps directly to Stripe subscription lifecycle states.

| Value | Description |
|---|---|
| `trialing` | In a free trial period; will convert or cancel at trial end |
| `active` | Paid and current |
| `past_due` | Payment failed; in grace period awaiting retry |
| `cancelled` | Explicitly cancelled; access continues until period end |
| `unpaid` | Payment failed and grace period expired |
| `incomplete` | Initial payment pending (SCA flow in progress) |
| `incomplete_expired` | Initial payment was never completed within 23 hours |
| `paused` | Subscription is paused (Stripe Pause Collection) |

**Used in:** `shared.subscriptions.status`

---

#### `billing_status`

Payment transaction outcomes.

| Value | Description |
|---|---|
| `pending` | Payment intent created but not yet confirmed |
| `succeeded` | Payment collected successfully |
| `failed` | Payment attempt failed |
| `refunded` | Full or partial refund issued |
| `disputed` | Cardholder filed a chargeback |

**Used in:** `shared.billing_transactions.status`

---

#### `device_platform`

Platform type for push notification device tokens.

| Value | Description |
|---|---|
| `ios` | Apple iOS device (APNs token) |
| `android` | Android device (FCM registration token) |
| `web` | Web browser (Web Push subscription) |

**Used in:** `shared.devices.platform`

---

#### `oauth_provider`

Supported OAuth 2.0 identity providers.

| Value | Description |
|---|---|
| `google` | Google Sign-In (Google Identity Services) |
| `github` | GitHub OAuth App |
| `facebook` | Facebook Login |
| `twitter` | Twitter (X) OAuth 2.0 |
| `linkedin` | LinkedIn OAuth 2.0 |

**Used in:** `shared.oauth_accounts.provider`

---

#### `notification_channel`

Delivery channel for outgoing notifications.

| Value | Description |
|---|---|
| `push` | Mobile / web push notification via FCM / APNs / Web Push |
| `email` | Email delivery via SMTP or transactional email provider |
| `sms` | SMS delivery via Twilio / MSG91 |
| `in_app` | In-application notification (no external dispatch) |

**Used in:** `shared.notifications.channel`, `screenerx.alerts.notification_channels`

---

#### `notification_type`

Classification of notification content.

| Value | Description |
|---|---|
| `alert` | User-configured price or fundamental alert triggered |
| `system` | Platform system message (maintenance, feature update) |
| `marketing` | Promotional or upsell notification |
| `report` | Scheduled report delivery (portfolio summary, tax statement) |
| `trade` | Order execution or trade confirmation |
| `news` | Breaking news or price-sensitive announcement |

**Used in:** `shared.notifications.type`

---

#### `sentiment_label`

Five-point directional sentiment scale.

| Value | Description |
|---|---|
| `very_bearish` | Strongly negative sentiment; score typically in [-1.0, -0.6] |
| `bearish` | Mildly negative sentiment; score in (-0.6, -0.2] |
| `neutral` | No directional bias; score in (-0.2, 0.2) |
| `bullish` | Mildly positive sentiment; score in [0.2, 0.6) |
| `very_bullish` | Strongly positive sentiment; score in [0.6, 1.0] |

**Used in:** `screenerx.news_articles.sentiment`, `screenerx.sentiment_data.label`

---

### Market Data Domain

#### `instrument_type`

Asset class classification for all instruments in the symbol master.

| Value | Description |
|---|---|
| `equity` | Listed company shares |
| `etf` | Exchange-traded fund |
| `index` | Market index (e.g. NIFTY50, SENSEX) — non-tradeable reference |
| `futures` | Futures contract |
| `options` | Options contract (call or put) |
| `mutual_fund` | Mutual fund unit / NAV |
| `bond` | Fixed-income debt instrument |
| `currency` | Currency pair for forex trading |
| `commodity` | Commodity contract (gold, crude, etc.) |

**Used in:** `screenerx.symbols.instrument_type`

---

#### `order_book_side`

Side of the Level-2 order book.

| Value | Description |
|---|---|
| `bid` | Buy-side orders — sorted descending by price |
| `ask` | Sell-side orders — sorted ascending by price |

**Used in:** `screenerx.order_books.side`

---

#### `corporate_action_type`

Types of corporate events that affect share price and quantity.

| Value | Description |
|---|---|
| `dividend` | Cash or stock dividend declaration |
| `split` | Stock split (e.g. 2:1 increases share count) |
| `bonus` | Bonus issue (free shares to existing shareholders) |
| `rights` | Rights issue (new shares offered at a discount) |
| `merger` | Company merger or acquisition |
| `delisting` | Voluntary or involuntary delisting from exchange |
| `buyback` | Company buying back its own shares |
| `amalgamation` | Company amalgamation / consolidation |
| `demerger` | Spin-off of a business unit as a separate entity |

**Used in:** `screenerx.corporate_actions.action_type`

---

#### `dividend_type`

Classification of dividend announcement timing.

| Value | Description |
|---|---|
| `interim` | Dividend declared before year-end (mid-year) |
| `final` | Dividend declared at year-end after final accounts |
| `special` | One-time extraordinary dividend (e.g. from asset sale proceeds) |

**Used in:** `screenerx.dividends.dividend_type`

---

#### `period_type`

Accounting period classification for financial statements.

| Value | Description |
|---|---|
| `Q1` | First quarter (April–June for Indian FY) |
| `Q2` | Second quarter (July–September) |
| `Q3` | Third quarter (October–December) |
| `Q4` | Fourth quarter (January–March) |
| `Annual` | Full financial year results |
| `TTM` | Trailing twelve months (rolling annual) |

**Used in:** `screenerx.earnings`, `screenerx.balance_sheets`, `screenerx.income_statements`, `screenerx.cash_flows`

---

#### `event_importance`

Significance level for macro-economic calendar events.

| Value | Description |
|---|---|
| `low` | Minor data release; limited market impact expected |
| `medium` | Moderate significance; may cause brief volatility |
| `high` | Major release (RBI policy, GDP, CPI, Fed decision); significant market impact |

**Used in:** `screenerx.economic_events.importance`

---

#### `sentiment_source`

Data source for NLP sentiment signals.

| Value | Description |
|---|---|
| `news` | Financial news articles and press releases |
| `twitter` | Twitter / X posts mentioning the ticker |
| `reddit` | Reddit posts from r/IndiaInvestments, r/stocks, etc. |
| `analyst` | Analyst research notes and price target changes |
| `options_flow` | Unusual options activity signals (put/call ratio) |
| `insider` | Insider buying/selling disclosed to exchanges |

**Used in:** `screenerx.sentiment_data.source`

---

### Screener Domain

#### `filter_operator`

Comparison operators available in the screener filter engine.

| Value | Description |
|---|---|
| `gt` | Greater than |
| `lt` | Less than |
| `gte` | Greater than or equal to |
| `lte` | Less than or equal to |
| `eq` | Equal to |
| `neq` | Not equal to |
| `in` | Value is in a list |
| `not_in` | Value is not in a list |
| `between` | Value is between two bounds (inclusive) |
| `contains` | String contains substring (case-insensitive) |
| `starts_with` | String starts with prefix |
| `ends_with` | String ends with suffix |
| `is_null` | Field is NULL |
| `is_not_null` | Field is not NULL |

**Used in:** `screenerx.screener_filters.operator`

---

### Portfolio Domain

#### `portfolio_type`

Classification of portfolio intent.

| Value | Description |
|---|---|
| `real` | Live portfolio tracking real money and executed trades |
| `paper` | Simulated portfolio with virtual money for testing strategies |
| `model` | Theoretical model portfolio for research (not synced to any account) |

**Used in:** `screenerx.portfolios.portfolio_type`

---

#### `transaction_type`

All valid portfolio ledger transaction types.

| Value | Description |
|---|---|
| `buy` | Security purchase |
| `sell` | Security sale |
| `dividend` | Dividend received (cash) |
| `split` | Share count adjusted for stock split |
| `bonus` | Additional shares from bonus issue |
| `transfer_in` | Position transferred into this portfolio |
| `transfer_out` | Position transferred out of this portfolio |
| `interest` | Interest income (e.g. from liquid funds) |
| `fee` | Brokerage fee or platform charge deducted |

**Used in:** `screenerx.portfolio_transactions.txn_type`

---

#### `goal_type`

Financial goal category for goal-based investing.

| Value | Description |
|---|---|
| `retirement` | Retirement corpus accumulation |
| `education` | Education fund (child's college, own upskilling) |
| `house` | Down payment or full home purchase |
| `emergency` | Emergency fund (3–12 months expenses) |
| `travel` | Travel / vacation fund |
| `custom` | User-defined custom goal |

**Used in:** `screenerx.goals.goal_type`

---

#### `goal_status`

Lifecycle state of a financial goal.

| Value | Description |
|---|---|
| `active` | Goal is being actively funded |
| `completed` | Target amount reached or target date passed with sufficient corpus |
| `paused` | User has temporarily stopped contributions |
| `cancelled` | Goal abandoned |

**Used in:** `screenerx.goals.status`

---

#### `rebalancing_rule_type`

Strategy for triggering portfolio rebalancing.

| Value | Description |
|---|---|
| `target_weight` | Rebalance when actual weights deviate from targets by threshold_pct |
| `threshold` | Rebalance when any single asset exceeds threshold_pct of portfolio value |
| `calendar` | Rebalance on a fixed schedule (monthly / quarterly / annually) |

**Used in:** `screenerx.rebalancing_rules.rule_type`

---

### Trading Domain

#### `account_type`

Types of brokerage accounts.

| Value | Description |
|---|---|
| `demat` | Demat (securities custody) account |
| `trading` | Trading account for equity and F&O |
| `commodity` | MCX/NCDEX commodity trading account |
| `currency` | Currency derivatives account |
| `mutual_fund` | Direct mutual fund account |

**Used in:** `quantnova.broker_accounts.account_type`

---

#### `order_type`

Order execution instruction types.

| Value | Description |
|---|---|
| `market` | Execute immediately at best available price |
| `limit` | Execute only at specified price or better |
| `stop` | Market order triggered when stop price is reached |
| `stop_limit` | Limit order triggered when stop price is reached |
| `bracket` | Order with automatic profit target and stop-loss legs |
| `cover` | Intraday order with mandatory stop-loss |
| `trailing_stop` | Stop-loss that trails the price by a fixed amount |

**Used in:** `quantnova.orders.order_type`

---

#### `order_side`

Direction of the trade.

| Value | Description |
|---|---|
| `buy` | Purchase order |
| `sell` | Sale order (or short sale) |

**Used in:** `quantnova.orders.side`

---

#### `product_type`

Margin and settlement product classification used by Indian brokers.

| Value | Description |
|---|---|
| `intraday` | MIS (Margin Intraday Square-off) — must be squared off before EOD |
| `delivery` | CNC (Cash and Carry) — held in demat |
| `futures` | Futures segment (F&O) |
| `options` | Options segment (F&O) |
| `currency` | Currency derivatives |
| `commodity` | MCX/NCDEX commodity segment |

**Used in:** `quantnova.orders.product_type`, `quantnova.positions.product_type`

---

#### `order_status`

Order lifecycle states.

| Value | Description |
|---|---|
| `pending` | Created but not yet submitted to broker |
| `open` | Submitted and resting in the exchange order book |
| `partial` | Partially filled; remainder still open |
| `filled` | Fully executed |
| `cancelled` | Cancelled by user or system |
| `rejected` | Rejected by broker or exchange (validation failure, risk limit) |
| `expired` | Day order expired at market close without fill |
| `amo_pending` | After-Market Order waiting for next session open |

**Used in:** `quantnova.orders.status`

---

#### `order_validity`

Time-in-force instructions for order execution.

| Value | Description |
|---|---|
| `day` | Valid for the current trading session only |
| `ioc` | Immediate or Cancel — execute immediately, cancel unfilled portion |
| `gtc` | Good Till Cancelled — remains active until filled or explicitly cancelled |
| `gtd` | Good Till Date — expires on a specified date |
| `amo` | After Market Order — queued for next session open |

**Used in:** `quantnova.orders.validity`

---

#### `risk_limit_type`

Categories of risk controls applied at order placement.

| Value | Description |
|---|---|
| `max_position_size` | Maximum value of a single position (in base currency) |
| `max_daily_loss` | Maximum P&L loss permitted in a single trading day |
| `max_drawdown` | Maximum portfolio drawdown from peak allowed |
| `sector_concentration` | Maximum % of portfolio in a single GICS sector |
| `var` | Value at Risk limit (95% or 99% confidence) |
| `max_leverage` | Maximum gross leverage ratio |

**Used in:** `quantnova.risk_limits.limit_type`

---

#### `breach_action`

Action taken when a risk limit is breached.

| Value | Description |
|---|---|
| `alert` | Send notification to user; allow the action to proceed |
| `block` | Reject the order or operation |
| `liquidate` | Automatically close all or part of the position |

**Used in:** `quantnova.risk_limits.on_breach`

---

### Strategy & Backtest Domain

#### `strategy_type`

Algorithmic strategy classification.

| Value | Description |
|---|---|
| `momentum` | Trend-following — buy strength, sell weakness |
| `mean_reversion` | Fade extremes — buy oversold, sell overbought |
| `arbitrage` | Exploit price discrepancies across instruments or markets |
| `ml` | Machine learning model-driven entry/exit |
| `manual` | Rule-based discretionary strategy (human-coded logic) |
| `factor` | Multi-factor (value, momentum, quality, size) systematic strategy |
| `pairs_trading` | Long/short correlated instrument pairs |
| `statistical_arb` | Statistical arbitrage across a larger universe |

**Used in:** `quantnova.strategies.strategy_type`

---

#### `backtest_status`

State of a backtest job.

| Value | Description |
|---|---|
| `queued` | Awaiting compute resource allocation |
| `running` | Currently executing on the backtest engine |
| `completed` | Finished successfully; results available |
| `failed` | Execution failed; error_message populated |
| `cancelled` | User cancelled before completion |

**Used in:** `quantnova.backtests.status`

---

#### `signal_type`

Trading signal direction and action.

| Value | Description |
|---|---|
| `long` | Initiate or increase a long position |
| `short` | Initiate or increase a short position |
| `exit` | Close an existing position entirely |
| `scale_in` | Add to an existing position |
| `scale_out` | Reduce an existing position |

**Used in:** `quantnova.alpha_signals.signal_type`

---

### AI/ML Domain

#### `ml_model_type`

Machine learning model category.

| Value | Description |
|---|---|
| `classification` | Predicts categorical output (buy/sell/hold) |
| `regression` | Predicts continuous value (price target, return) |
| `clustering` | Groups instruments by similarity |
| `nlp` | Natural language processing (sentiment, news classification) |
| `rl` | Reinforcement learning (policy-based trading agent) |
| `time_series` | Time-series forecasting (LSTM, Transformer, Prophet) |
| `anomaly_detection` | Detects abnormal patterns (fraud, unusual trades) |

**Used in:** `quantnova.ml_models.model_type`

---

#### `run_status`

Status of an async compute job (training or optimisation run).

| Value | Description |
|---|---|
| `pending` | Job created, waiting to start |
| `running` | Job is actively executing |
| `completed` | Job finished successfully |
| `failed` | Job failed; error details in the record |
| `cancelled` | Job cancelled by user before completion |

**Used in:** `quantnova.training_runs.status`, `quantnova.optimization_runs.status`

---

#### `recommendation_type`

AI-generated investment recommendation categories.

| Value | Description |
|---|---|
| `buy` | Model recommends initiating or adding to a long position |
| `sell` | Model recommends exiting or shorting |
| `hold` | Model recommends maintaining existing position without action |
| `watch` | Not enough conviction to act; monitor closely |
| `avoid` | Negative outlook; do not buy |

**Used in:** `quantnova.ai_recommendations.recommendation`, `quantnova.inference_logs.prediction`

---

#### `drift_type`

Type of model degradation detected.

| Value | Description |
|---|---|
| `data` | Input data distribution has shifted (e.g. market regime change) |
| `concept` | Relationship between inputs and outputs has changed |
| `model` | Model performance metrics have degraded over time |
| `covariate` | Individual feature distributions have shifted |

**Used in:** `quantnova.drift_detection.drift_type`

---

### Alerts Domain

#### `alert_type`

Category of condition the alert monitors.

| Value | Description |
|---|---|
| `price` | LTP crosses or reaches a price level |
| `volume` | Volume exceeds a threshold (absolute or relative) |
| `technical` | Technical indicator condition (RSI, MACD, moving average) |
| `fundamental` | Fundamental ratio threshold (P/E, P/B, etc.) |
| `news` | News article published mentioning the symbol |
| `custom` | User-defined formula-based condition |
| `earnings` | Earnings announcement within N days |
| `insider` | Insider buying or selling disclosed |

**Used in:** `screenerx.alerts.alert_type`

---

### Institutional Holdings Domain

#### `institution_type`

Category of institutional investor.

| Value | Description |
|---|---|
| `fii` | Foreign Institutional Investor |
| `dii` | Domestic Institutional Investor |
| `insurance` | Insurance companies (LIC, private insurers) |
| `bank` | Scheduled commercial banks |
| `mf` | Mutual fund schemes |
| `hedge_fund` | Hedge funds and AIFs |
| `pension_fund` | Pension and provident funds |

**Used in:** `screenerx.institutional_holdings.inst_type`

---

### Analyst Ratings Domain

#### `analyst_rating`

Standard sell-side analyst recommendation scale.

| Value | Description |
|---|---|
| `strong_buy` | High-conviction buy; significant upside to target price |
| `buy` | Positive outlook; recommend accumulating |
| `hold` | Neutral; maintain current position; limited upside/downside |
| `sell` | Negative outlook; recommend reducing |
| `strong_sell` | High-conviction sell; significant downside |
| `not_rated` | Analyst has coverage but no active rating |

**Used in:** `screenerx.analyst_ratings.rating`

---

### NDFL Schema Enums (schema-prefixed)

These types are defined directly in `ndfl/postgres/ddl/001_tax_years.sql` using `CREATE TYPE IF NOT EXISTS ndfl.<name>`.

#### `ndfl.filing_status_enum`

| Value | Description |
|---|---|
| `not_started` | Tax year record created but no filing activity started |
| `in_progress` | Filing preparation underway; computation may not be finalised |
| `filed` | ITR has been submitted to the Income Tax portal |
| `revised` | Original ITR has been revised (revised return filed) |
| `defective` | Filed return was flagged as defective by the IT department |

**Used in:** `ndfl.tax_years.filing_status`

---

#### `ndfl.itr_form_type_enum`

| Value | Description |
|---|---|
| `ITR1` | Sahaj — for salaried individuals with income up to ₹50L |
| `ITR2` | For individuals and HUFs with capital gains or foreign income |
| `ITR3` | For individuals with income from business or profession |
| `ITR4` | Sugam — for individuals opting for presumptive taxation scheme |

**Used in:** `ndfl.tax_years.itr_form_type`

---

## Standard Column Conventions

The following columns appear on most tables with consistent semantics.

| Column | Type | Convention |
|---|---|---|
| `id` | UUID NOT NULL DEFAULT gen_random_uuid() | Every table has a UUID primary key named `id`. Never an integer serial. |
| `tenant_id` | UUID NOT NULL | Present on all user-owned tables that need tenant isolation. Set on INSERT; never updated. |
| `created_at` | TIMESTAMPTZ NOT NULL DEFAULT NOW() | Row creation timestamp. Always TIMESTAMPTZ (UTC). Never TIMESTAMP. |
| `updated_at` | TIMESTAMPTZ NOT NULL DEFAULT NOW() | Last mutation timestamp. Maintained by `users_trigger` / domain triggers. |
| `deleted_at` | TIMESTAMPTZ | Soft-delete timestamp. NULL = active. Presence = soft-deleted. Always check `WHERE deleted_at IS NULL` in queries. |
| `created_by` | UUID | UUID of the user who created this row. Nullable (system-created rows have NULL). |
| `updated_by` | UUID | UUID of the user who last modified this row. Nullable. |
| `version` | INTEGER | Optimistic concurrency lock version counter. Incremented on every UPDATE. Present on high-contention tables (orders, strategies). |
| `metadata` | JSONB NOT NULL DEFAULT '{}' | Flexible attribute bag for fields not worthy of a dedicated column. Never NULL — defaults to empty object. |
| `is_active` | BOOLEAN NOT NULL DEFAULT TRUE | Logical active/inactive flag. Different from soft-delete: an inactive record is still visible but excluded from active queries. |

### Soft-delete convention

All tables with a `deleted_at` column use soft-delete:

```sql
-- Soft-delete a row
UPDATE screenerx.portfolios
SET deleted_at = NOW(), updated_by = '<user_id>'
WHERE id = '<portfolio_id>';

-- Query active rows only
SELECT * FROM screenerx.portfolios
WHERE deleted_at IS NULL;
```

Views (e.g. `v_portfolio_holdings`) always filter `WHERE deleted_at IS NULL`.

---

## Naming Conventions

### Schema names

All lowercase, short identifiers: `shared`, `screenerx`, `quantnova`, `ndfl`.

### Table names

Lowercase `snake_case`, always **plural**:

```
users, portfolios, market_data_ticks, broker_accounts, tax_years
```

### Column names

Lowercase `snake_case`:

```
user_id, created_at, broker_order_id, stripe_subscription_id
```

### Primary keys

Always named `id`, always UUID:

```sql
id UUID NOT NULL DEFAULT gen_random_uuid()
```

### Foreign key columns

Named `{referenced_table_singular}_id`:

```
user_id       → references shared.users(id)
symbol_id     → references screenerx.symbols(id)
portfolio_id  → references screenerx.portfolios(id)
strategy_id   → references quantnova.strategies(id)
```

### Foreign key constraint names

Pattern: `{table}_{fk_column}_fk`:

```sql
CONSTRAINT orders_user_fk FOREIGN KEY (user_id) REFERENCES shared.users (id)
CONSTRAINT orders_symbol_fk FOREIGN KEY (symbol_id) REFERENCES screenerx.symbols (id)
```

### Unique constraint names

Pattern: `{table}_{columns}_unique`:

```sql
CONSTRAINT users_email_tenant_unique UNIQUE (email, tenant_id)
CONSTRAINT symbols_ticker_exchange_unique UNIQUE (ticker, exchange_id)
```

### Check constraint names

Pattern: `{table}_{column_or_description}`:

```sql
CONSTRAINT users_email_format CHECK (email ~* '^...$')
CONSTRAINT orders_limit_requires_price CHECK (order_type NOT IN ('limit','stop_limit') OR price IS NOT NULL)
```

### Index names

Pattern: `idx_{table}_{column(s)}`:

```sql
idx_users_email
idx_users_tenant_id
idx_market_data_ticks_symbol_timestamp
```

### Enum type names

Lowercase `snake_case`, ending in meaningful noun (not `_enum` — except `ndfl` schema-prefixed types which use `_enum` to avoid conflicts):

```
user_status, plan_type, order_type, sentiment_label
ndfl.filing_status_enum, ndfl.itr_form_type_enum
```

---

## Data Type Decisions

### UUID vs BIGSERIAL

**Decision: UUID for all primary keys.**

Rationale:
- UUIDs are safe to generate client-side without a round-trip to the database — important for event sourcing and optimistic inserts.
- UUIDs do not reveal insertion order or row count to clients (no enumerable integer IDs in public URLs).
- Cross-schema and cross-database merges and migrations do not require re-keying.
- `gen_random_uuid()` from `pgcrypto` is cryptographically random; no collision risk at any realistic scale.

**Drawback acknowledged:** Random UUID primary keys cause B-tree index fragmentation under heavy insert load. For the highest-volume tables (`market_data_ticks`, `pnl_snapshots`), TimescaleDB chunk pruning and time-range queries mitigate this — most range scans are on `(symbol_id, timestamp)` which is a compound key with timestamp as the leading range dimension.

---

### NUMERIC vs FLOAT (REAL / DOUBLE PRECISION)

**Decision: `NUMERIC(18,6)` for prices and quantities; `NUMERIC(18,2)` for monetary amounts; `NUMERIC` (unconstrained) for ratios and percentages.**

Rationale:
- `FLOAT` / `DOUBLE PRECISION` use IEEE 754 binary floating-point, which cannot exactly represent most decimal fractions. `0.1 + 0.2 ≠ 0.3` in floating-point arithmetic.
- Financial calculations (tax, P&L, portfolio value) require exact decimal arithmetic. Use `NUMERIC` everywhere money or prices are stored.
- `NUMERIC(18,6)` accommodates prices up to 999,999,999,999.999999 — sufficient for any currently listed security price.
- `NUMERIC(18,2)` accommodates monetary amounts to 2 decimal places, in crores (Indian) or billions (US).

**Exceptions:**
- `screenerx.sentiment_data.score` — stored as `NUMERIC(5,4)` (range [-1.0000, 1.0000]) since 4 decimal places is sufficient for NLP scores.
- `quantnova.alpha_signals.strength` / `confidence` — `NUMERIC` unconstrained since these are model outputs with varying precision.

---

### TIMESTAMPTZ vs TIMESTAMP

**Decision: Always `TIMESTAMPTZ` (timestamp with time zone).**

Rationale:
- `TIMESTAMPTZ` stores values in UTC internally and converts to the session timezone for display. This is always correct across timezone boundaries.
- `TIMESTAMP` (without timezone) stores the literal text representation — if the server timezone changes or a user connects from a different timezone, queries return wrong times.
- All financial data (trade times, order placements, alert triggers) must be stored in UTC. Using `TIMESTAMPTZ` enforces this.

**Exceptions:** `DATE` columns (e.g. `transaction_date`, `listing_date`, `snapshot_date`) are appropriate where only the calendar date (not the time of day) is meaningful.

---

### VARCHAR vs TEXT

**Decision: `VARCHAR(N)` for fields with a meaningful maximum length; `TEXT` for unbounded fields.**

Rules applied:
- `VARCHAR(320)` for email addresses (RFC 5321 maximum)
- `VARCHAR(50)` for ticker symbols (exchange codes, ISIN, CUSIP)
- `VARCHAR(255)` for names, titles, URLs
- `VARCHAR(500)` for longer names (instrument full names may be long)
- `TEXT` for body text (article bodies, strategy code, rationale) where no meaningful length limit applies
- `CHAR(2)` for fixed-length country codes (ISO 3166-1)
- `CHAR(3)` for fixed-length currency codes (ISO 4217)

---

### BOOLEAN conventions

- Default to `FALSE` for opt-in flags (`email_verified`, `is_read`, `cancel_at_period_end`)
- Default to `TRUE` for opt-out flags (`is_active`, `is_active` on exchange/symbol tables)
- Never use `SMALLINT` or `INTEGER` (0/1) as a boolean substitute — use native `BOOLEAN`

---

### JSONB vs JSON

**Decision: Always `JSONB`, never `JSON`.**

Rationale:
- `JSONB` stores a parsed binary representation; `JSON` stores the raw text.
- `JSONB` supports GIN indexes for containment queries (`@>`, `?`, `?|`, `?&`).
- `JSONB` is queryable with operators and path expressions.
- `JSONB` deduplicates object keys and preserves no whitespace — slightly smaller on disk.

**Convention:** All JSONB columns default to `'{}'::jsonb` (not NULL) so `metadata->>'key'` can be called without NULL guards.

---

### Array types

PostgreSQL native arrays are used where a column holds a small, ordered, homogeneous set of values:

- `TEXT[]` — `symbols.trade_condition`, `api_keys.scopes`, `devices.subscribed_symbols`, `ml_models.tags`
- `notification_channel[]` — `screenerx.alerts.notification_channels`
- `UUID[]` — not used; prefer JSONB arrays for UUID lists to avoid type casting friction with application ORMs

GIN indexes are applied to TEXT[] columns used in `ANY` or `@>` containment queries:

```sql
CREATE INDEX idx_news_symbol_tickers ON screenerx.news_articles USING GIN (symbol_tickers);
```
