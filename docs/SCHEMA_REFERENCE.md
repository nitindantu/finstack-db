# Schema Reference

Complete table-by-table reference for all 105 tables across the four PostgreSQL schemas.

## Table of Contents

- [shared schema (15 tables)](#shared-schema)
- [screenerx schema (59 tables)](#screenerx-schema)
- [quantnova schema (23 tables)](#quantnova-schema)
- [ndfl schema (8 tables)](#ndfl-schema)

## AI Platform Tables (v1.3.0)

### screenerx.ai_copilot_sessions
Tracks AI chat sessions per user. Stores session type, status, token usage totals, and context snapshots.

### screenerx.ai_copilot_messages
Individual messages within copilot sessions. Records role, content, token counts, latency, model ID, confidence scores, and tool call metadata.

### screenerx.risk_profiles
SEBI risk-o-meter compliant user risk profiles. Stores questionnaire responses, risk score (0–100), risk category, recommended asset allocation, and detected behavioral biases.

### screenerx.financial_goals
User financial goals (retirement, education, house, FIRE, etc.). Includes target amount, monthly contribution, target date, and Monte Carlo simulation results.

### screenerx.retirement_plans
Retirement corpus planning. Captures current/retirement ages, corpus sources (NPS, EPF, PPF), withdrawal strategy, and 10,000-scenario simulation results.

### screenerx.portfolio_analyses
Portfolio analytics snapshots including Sharpe ratio, Sortino ratio, max drawdown, sector allocation, and AI-generated insights.

### screenerx.ai_investment_recommendations
Personalized AI investment recommendations per user. Stores instrument type, recommendation type (buy/sell/hold), conviction level, target allocation, rationale, and confidence score.

### screenerx.market_intelligence_summaries
AI-generated market summaries with 2-hour cache TTL. Covers daily brief, sector rotation, macro outlook, and earnings summaries.

### screenerx.financial_health_scores
Composite financial health score (0–100) with grade. Sub-scores: portfolio diversification, goal progress, risk alignment, emergency preparedness.

### shared.advisor_clients
Advisor-client relationships for SEBI-registered advisor workflows. Tracks assignment date, status, and notes.

### shared.advisor_approvals
Human-in-loop approval workflow for AI recommendations requiring advisor sign-off before delivery to clients.

---

## shared schema

### shared.users

**Purpose:** Core user accounts for all tenants on the platform.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Unique user identifier (gen_random_uuid) |
| `tenant_id` | UUID NOT NULL | Tenant/organisation this user belongs to |
| `email` | VARCHAR(320) NOT NULL | Email address, unique per tenant |
| `password_hash` | TEXT | bcrypt/argon2 hash; NULL for OAuth-only users |
| `full_name` | VARCHAR(255) NOT NULL | Display name |
| `phone` | VARCHAR(20) | E.164 format phone number |
| `avatar_url` | TEXT | Profile picture URL |
| `email_verified` | BOOLEAN | Whether email was confirmed |
| `phone_verified` | BOOLEAN | Whether phone was confirmed via OTP |
| `status` | user_status | active / inactive / suspended / deleted |
| `plan_type` | plan_type | free / basic / premium / enterprise |
| `last_login_at` | TIMESTAMPTZ | Most recent successful login timestamp |
| `login_count` | INTEGER | Running count of successful logins |
| `metadata` | JSONB | Flexible attribute bag |
| `created_at` | TIMESTAMPTZ | Row creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp |
| `deleted_at` | TIMESTAMPTZ | Soft-delete timestamp; NULL = active |
| `created_by` | UUID | User who created this row |
| `updated_by` | UUID | User who last modified this row |

**Relationships:** Referenced by virtually every other table in all schemas.
**Indexes:** email+tenant_id (unique), status, tenant_id, deleted_at.
**Special notes:** RLS enabled; tenant_isolation policy applied.

---

### shared.roles

**Purpose:** Named RBAC roles (admin, analyst, trader, viewer, etc.).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Role identifier |
| `name` | VARCHAR(100) NOT NULL UNIQUE | Role name |
| `description` | TEXT | Human-readable description |
| `is_system` | BOOLEAN | TRUE = built-in, cannot be deleted |
| `metadata` | JSONB | Extra attributes |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp |

**Relationships:** Referenced by user_roles, role_permissions.

---

### shared.permissions

**Purpose:** Granular permission catalogue — resource + action pairs.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Permission identifier |
| `resource` | VARCHAR(100) NOT NULL | Resource name (e.g. portfolio, order, screener) |
| `action` | VARCHAR(50) NOT NULL | Action (create, read, update, delete, execute) |
| `description` | TEXT | What this permission allows |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

**Relationships:** Referenced by role_permissions.
**Special notes:** Unique constraint on (resource, action).

---

### shared.user_roles

**Purpose:** Junction table assigning roles to users with optional expiry.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Assignment identifier |
| `user_id` | UUID FK → shared.users | User receiving the role |
| `role_id` | UUID FK → shared.roles | Role being assigned |
| `granted_by` | UUID FK → shared.users | User who granted this role |
| `granted_at` | TIMESTAMPTZ | When the role was assigned |
| `expires_at` | TIMESTAMPTZ | Optional expiry; NULL = indefinite |

**Indexes:** user_id, role_id, expires_at.

---

### shared.role_permissions

**Purpose:** Junction table linking roles to their permitted actions.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Mapping identifier |
| `role_id` | UUID FK → shared.roles | Role |
| `permission_id` | UUID FK → shared.permissions | Permission |
| `created_at` | TIMESTAMPTZ | When permission was granted to role |

**Special notes:** Unique constraint on (role_id, permission_id).

---

### shared.sessions

**Purpose:** Active login sessions with device fingerprinting and refresh token tracking.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Session identifier |
| `user_id` | UUID FK → shared.users | Owning user |
| `refresh_token_hash` | TEXT UNIQUE | SHA-256 hash of the refresh token |
| `device_id` | VARCHAR(255) | Client-reported device fingerprint |
| `user_agent` | TEXT | Browser / app user-agent string |
| `ip_address` | VARCHAR(45) | IPv4 or IPv6 client address |
| `expires_at` | TIMESTAMPTZ NOT NULL | Session hard expiry |
| `created_at` | TIMESTAMPTZ | Session creation timestamp |
| `last_seen_at` | TIMESTAMPTZ | Most recent activity timestamp |
| `revoked_at` | TIMESTAMPTZ | Manual revocation timestamp; NULL = active |

**Indexes:** user_id, refresh_token_hash, expires_at.

---

### shared.api_keys

**Purpose:** Hashed API keys for programmatic access with per-key scopes.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Key record identifier |
| `user_id` | UUID FK → shared.users | Key owner |
| `name` | VARCHAR(255) NOT NULL | Human-readable key name |
| `key_hash` | TEXT UNIQUE NOT NULL | SHA-256 hash of the plaintext key |
| `key_prefix` | VARCHAR(10) | First 8 chars of key for display (e.g. `fsk_abc1`) |
| `scopes` | TEXT[] | Array of allowed scopes |
| `expires_at` | TIMESTAMPTZ | Optional expiry |
| `last_used_at` | TIMESTAMPTZ | Last successful authentication timestamp |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `revoked_at` | TIMESTAMPTZ | Revocation timestamp |

**Indexes:** key_hash (unique), user_id.

---

### shared.subscriptions

**Purpose:** Stripe-backed subscription records per user.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Subscription record identifier |
| `user_id` | UUID FK → shared.users | Subscriber |
| `plan_type` | plan_type NOT NULL | free / basic / premium / enterprise |
| `status` | subscription_status | trialing / active / past_due / cancelled / unpaid / paused |
| `stripe_subscription_id` | VARCHAR(255) UNIQUE | Stripe `sub_xxx` object ID |
| `stripe_customer_id` | VARCHAR(255) | Stripe `cus_xxx` object ID |
| `current_period_start` | TIMESTAMPTZ | Billing period start |
| `current_period_end` | TIMESTAMPTZ | Billing period end |
| `cancel_at_period_end` | BOOLEAN | TRUE = will not auto-renew |
| `trial_end` | TIMESTAMPTZ | Trial end date; NULL if no trial |
| `metadata` | JSONB | Stripe webhook payload snapshot |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp |
| `deleted_at` | TIMESTAMPTZ | Soft-delete |

**Relationships:** One-to-many with billing_transactions.

---

### shared.billing_transactions

**Purpose:** Immutable payment history linked to subscriptions.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Transaction identifier |
| `user_id` | UUID FK → shared.users | Payer |
| `subscription_id` | UUID FK → shared.subscriptions | Associated subscription |
| `amount` | NUMERIC(10,2) NOT NULL | Amount charged in `currency` |
| `currency` | CHAR(3) NOT NULL | ISO 4217 currency code |
| `status` | billing_status | pending / succeeded / failed / refunded / disputed |
| `stripe_payment_intent_id` | VARCHAR(255) | Stripe `pi_xxx` ID |
| `stripe_invoice_id` | VARCHAR(255) | Stripe `in_xxx` invoice ID |
| `description` | TEXT | Human-readable transaction description |
| `metadata` | JSONB | Full Stripe event payload |
| `created_at` | TIMESTAMPTZ | Transaction timestamp |

**Indexes:** user_id, subscription_id, status, created_at.

---

### shared.audit_logs

**Purpose:** Generic append-only audit trail written by trigger on all mutating operations.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Log entry identifier |
| `user_id` | UUID FK → shared.users | User who performed the action (NULL for system) |
| `table_name` | VARCHAR(100) NOT NULL | Schema-qualified table (e.g. `screenerx.portfolios`) |
| `operation` | VARCHAR(10) NOT NULL | INSERT / UPDATE / DELETE |
| `record_id` | UUID | PK of the affected row |
| `old_data` | JSONB | Row state before mutation (NULL for INSERT) |
| `new_data` | JSONB | Row state after mutation (NULL for DELETE) |
| `ip_address` | VARCHAR(45) | Client IP from session context |
| `session_id` | UUID | Active session at the time of change |
| `created_at` | TIMESTAMPTZ NOT NULL | Audit timestamp |

**Indexes:** user_id, table_name, record_id, created_at (DESC).
**Special notes:** No UPDATE or DELETE allowed on this table. Append-only.

---

### shared.user_preferences

**Purpose:** Per-user application settings stored as a JSONB document.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Preference record identifier |
| `user_id` | UUID FK → shared.users UNIQUE | One record per user |
| `preferences` | JSONB NOT NULL | Key-value settings (theme, language, notifications, dashboard layout, etc.) |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp |

---

### shared.devices

**Purpose:** Push notification device tokens for mobile and web clients.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Device registration identifier |
| `user_id` | UUID FK → shared.users | Device owner |
| `device_token` | TEXT NOT NULL UNIQUE | FCM/APNs/Web Push token |
| `platform` | device_platform NOT NULL | ios / android / web |
| `device_name` | VARCHAR(255) | Human-readable device name |
| `app_version` | VARCHAR(20) | Installed app version |
| `is_active` | BOOLEAN | FALSE = deregistered or token expired |
| `registered_at` | TIMESTAMPTZ | First registration timestamp |
| `last_active_at` | TIMESTAMPTZ | Last push delivery timestamp |

**Indexes:** user_id, device_token (unique), platform.

---

### shared.oauth_accounts

**Purpose:** Links users to OAuth provider identities (Google, GitHub, etc.).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | OAuth link identifier |
| `user_id` | UUID FK → shared.users | Platform user |
| `provider` | oauth_provider NOT NULL | google / github / facebook / twitter / linkedin |
| `provider_user_id` | VARCHAR(255) NOT NULL | Provider's user ID |
| `email` | VARCHAR(320) | Email from provider |
| `access_token` | TEXT | Encrypted access token (pgcrypto) |
| `refresh_token` | TEXT | Encrypted refresh token |
| `token_expires_at` | TIMESTAMPTZ | Access token expiry |
| `created_at` | TIMESTAMPTZ | Link creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last token refresh timestamp |

**Special notes:** Unique constraint on (provider, provider_user_id). access_token encrypted at rest.

---

### shared.notifications

**Purpose:** In-app, push, email, and SMS notification records.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Notification identifier |
| `user_id` | UUID FK → shared.users | Recipient |
| `type` | notification_type | alert / system / marketing / report / trade / news |
| `channel` | notification_channel | push / email / sms / in_app |
| `title` | VARCHAR(255) NOT NULL | Notification title |
| `body` | TEXT | Notification body |
| `is_read` | BOOLEAN | Whether the user has read it |
| `action_url` | TEXT | Deep link or URL to open on tap |
| `metadata` | JSONB | Entity references (e.g. alert_id, symbol_id) |
| `sent_at` | TIMESTAMPTZ | When notification was dispatched |
| `read_at` | TIMESTAMPTZ | When user read the notification |
| `created_at` | TIMESTAMPTZ | Record creation timestamp |

**Indexes:** user_id + is_read + created_at, type, channel.

---

## screenerx schema

### screenerx.exchanges

**Purpose:** Master list of stock and derivatives exchanges.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Exchange identifier |
| `code` | VARCHAR(20) UNIQUE NOT NULL | Short code: NSE, BSE, NYSE, NASDAQ, MCX |
| `name` | VARCHAR(255) NOT NULL | Full exchange name |
| `country` | CHAR(2) NOT NULL | ISO 3166-1 alpha-2 country code |
| `currency` | CHAR(3) NOT NULL | ISO 4217 base currency |
| `timezone` | VARCHAR(60) NOT NULL | IANA timezone (e.g. Asia/Kolkata) |
| `trading_hours` | JSONB | Day-of-week → open/close times |
| `is_active` | BOOLEAN | Whether exchange is currently active on platform |
| `metadata` | JSONB | Additional exchange attributes |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification timestamp |

**Seed data:** 8 exchanges: NSE, BSE, NYSE, NASDAQ, MCX, LSE, SGX, NCDEX.

---

### screenerx.symbols

**Purpose:** Master instrument list — all tradeable and reference instruments.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Symbol identifier |
| `exchange_id` | UUID FK → exchanges | Listing exchange |
| `ticker` | VARCHAR(50) NOT NULL | Exchange-specific trading symbol |
| `name` | VARCHAR(500) NOT NULL | Instrument full name |
| `isin` | VARCHAR(12) | 12-char International Securities ID |
| `cusip` | VARCHAR(9) | 9-char CUSIP (US instruments) |
| `sector` | VARCHAR(100) | GICS sector classification |
| `industry` | VARCHAR(200) | GICS industry |
| `market_cap_category` | VARCHAR(20) | large_cap / mid_cap / small_cap / micro_cap / nano_cap |
| `instrument_type` | instrument_type | equity / etf / index / futures / options / mutual_fund / bond / currency / commodity |
| `is_active` | BOOLEAN | Whether currently tradeable |
| `listing_date` | DATE | IPO / first trading date |
| `delisting_date` | DATE | Delisting date; NULL if active |
| `metadata` | JSONB | Additional attributes |

**Indexes:** ticker+exchange_id (unique), isin, sector, market_cap_category, is_active.
**Seed data:** 20 symbols (RELIANCE, TCS, INFY, HDFC, WIPRO, ICICIBANK, SBIN, HCLTECH, AXISBANK, BAJFINANCE on NSE/BSE; AAPL, MSFT, GOOGL, AMZN, TSLA on NASDAQ).

---

### screenerx.instrument_master

**Purpose:** Extended market microstructure metadata per instrument.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Record identifier |
| `symbol_id` | UUID FK → symbols UNIQUE | One record per symbol |
| `lot_size` | NUMERIC | Minimum lot size for F&O |
| `tick_size` | NUMERIC | Minimum price movement |
| `face_value` | NUMERIC | Par value per share |
| `market_cap` | NUMERIC | Current market capitalisation |
| `total_shares` | BIGINT | Total shares outstanding |
| `float_shares` | BIGINT | Publicly tradeable float |
| `circuit_limit_pct` | NUMERIC | Daily price band percentage |
| `last_updated` | DATE | Last data refresh date |

---

### screenerx.market_data_ticks

**Purpose:** Raw tick-by-tick trade and quote data.

| Column | Type | Description |
|---|---|---|
| `symbol_id` | UUID FK → symbols | Instrument |
| `timestamp` | TIMESTAMPTZ NOT NULL | Exchange timestamp |
| `price` | NUMERIC(18,6) NOT NULL | Last traded price |
| `volume` | BIGINT | Volume in this tick |
| `bid` | NUMERIC(18,6) | Best bid price |
| `ask` | NUMERIC(18,6) | Best ask price |
| `bid_size` | BIGINT | Bid quantity |
| `ask_size` | BIGINT | Ask quantity |
| `trade_condition` | TEXT[] | Exchange trade condition codes |
| `metadata` | JSONB | Additional tick data |

**Indexes:** (symbol_id, timestamp) composite PK; TimescaleDB time index.
**Special notes:** TimescaleDB hypertable. Chunk interval: 1 day. Space partitions: 16 on symbol_id. Compressed after 7 days. Retained for 90 days.

---

### screenerx.market_data_ohlcv

**Purpose:** Aggregated OHLCV candle data across multiple timeframes (1m, 5m, 15m, 1h, 1d).

| Column | Type | Description |
|---|---|---|
| `symbol_id` | UUID FK → symbols | Instrument |
| `timestamp` | TIMESTAMPTZ NOT NULL | Candle open time |
| `timeframe` | VARCHAR(5) NOT NULL | 1m / 5m / 15m / 1h / 1d |
| `open` | NUMERIC(18,6) | Opening price |
| `high` | NUMERIC(18,6) | High price |
| `low` | NUMERIC(18,6) | Low price |
| `close` | NUMERIC(18,6) | Closing price |
| `volume` | BIGINT | Total volume in period |
| `vwap` | NUMERIC(18,6) | Volume-weighted average price |
| `num_trades` | INTEGER | Number of trades in period |

**Special notes:** Separate hypertable per timeframe (market_data_1m through market_data_1d). Chunk intervals vary: 7 days (1m) to 1 year (1d).
**Seed data:** 975 daily (1d) OHLCV records across 20 symbols.

---

### screenerx.order_books

**Purpose:** Level-2 order book snapshots.

| Column | Type | Description |
|---|---|---|
| `symbol_id` | UUID FK → symbols | Instrument |
| `timestamp` | TIMESTAMPTZ NOT NULL | Snapshot timestamp |
| `side` | order_book_side | bid / ask |
| `price` | NUMERIC(18,6) | Price level |
| `quantity` | BIGINT | Aggregate quantity at this level |
| `num_orders` | INTEGER | Number of resting orders at this level |

**Special notes:** TimescaleDB hypertable. Chunk: 1 day. Space partitions: 8 on symbol_id.

---

### screenerx.corporate_actions

**Purpose:** Master record for corporate events (dividends, splits, bonuses, mergers).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Corporate action ID |
| `symbol_id` | UUID FK → symbols | Affected instrument |
| `action_type` | corporate_action_type | dividend / split / bonus / rights / merger / delisting / buyback |
| `ex_date` | DATE | Ex-date for the action |
| `record_date` | DATE | Record date |
| `pay_date` | DATE | Payment or execution date |
| `details` | JSONB | Action-specific data |
| `is_confirmed` | BOOLEAN | Whether officially confirmed |
| `created_at` | TIMESTAMPTZ | Record creation |
| `updated_at` | TIMESTAMPTZ | Last update |

---

### screenerx.dividends

**Purpose:** Dividend announcements and payment records.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Dividend record ID |
| `symbol_id` | UUID FK → symbols | Issuing company |
| `corporate_action_id` | UUID FK → corporate_actions | Parent corporate action |
| `dividend_type` | dividend_type | interim / final / special |
| `amount_per_share` | NUMERIC(18,6) NOT NULL | Dividend per share |
| `ex_date` | DATE NOT NULL | Ex-dividend date |
| `record_date` | DATE | Record date |
| `pay_date` | DATE | Payment date |
| `currency` | CHAR(3) | Currency of payment |
| `tax_rate_pct` | NUMERIC | Applicable TDS rate |

---

### screenerx.splits

**Purpose:** Stock split and bonus issue records.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Split record ID |
| `symbol_id` | UUID FK → symbols | Issuing company |
| `corporate_action_id` | UUID FK → corporate_actions | Parent corporate action |
| `split_ratio` | NUMERIC NOT NULL | e.g. 2 for 2:1 split, 0.5 for reverse split |
| `ex_date` | DATE NOT NULL | Ex-date |
| `notes` | TEXT | Additional context |

---

### screenerx.earnings

**Purpose:** Quarterly and annual earnings announcements.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Earnings record ID |
| `symbol_id` | UUID FK → symbols | Reporting company |
| `period` | period_type | Q1 / Q2 / Q3 / Q4 / Annual / TTM |
| `fiscal_year` | VARCHAR(10) | e.g. FY2025 |
| `announcement_date` | DATE | Date of results announcement |
| `revenue` | NUMERIC(18,2) | Revenue / net sales |
| `gross_profit` | NUMERIC(18,2) | Gross profit |
| `net_profit` | NUMERIC(18,2) | PAT (Profit After Tax) |
| `ebitda` | NUMERIC(18,2) | EBITDA |
| `eps` | NUMERIC(18,4) | Earnings per share (actual) |
| `eps_estimate` | NUMERIC(18,4) | Consensus EPS estimate |
| `revenue_estimate` | NUMERIC(18,2) | Consensus revenue estimate |

---

### screenerx.economic_events

**Purpose:** Macro-economic calendar events (GDP, CPI, RBI policy, etc.).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Event ID |
| `name` | VARCHAR(255) NOT NULL | Event name |
| `country` | CHAR(2) | Affected country (ISO 3166-1) |
| `importance` | event_importance | low / medium / high |
| `event_time` | TIMESTAMPTZ | Scheduled release time |
| `actual` | VARCHAR(50) | Actual released value |
| `forecast` | VARCHAR(50) | Consensus forecast |
| `previous` | VARCHAR(50) | Previous reading |
| `unit` | VARCHAR(30) | Unit of measure (%, bps, etc.) |
| `source` | VARCHAR(100) | Releasing body |

---

### screenerx.news_articles

**Purpose:** Financial news articles with symbol tagging and sentiment pre-classification.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Article identifier |
| `headline` | VARCHAR(500) NOT NULL | Article headline |
| `body` | TEXT | Full article body |
| `summary` | TEXT | AI-generated or editorial summary |
| `source` | VARCHAR(100) | Publication / news feed |
| `author` | VARCHAR(255) | Author name |
| `symbol_tickers` | TEXT[] | Array of mentioned tickers |
| `categories` | TEXT[] | Topic categories |
| `sentiment` | sentiment_label | very_bearish / bearish / neutral / bullish / very_bullish |
| `sentiment_score` | NUMERIC(5,4) | Float in [-1.0, 1.0] |
| `url` | TEXT | Original article URL |
| `image_url` | TEXT | Thumbnail image URL |
| `published_at` | TIMESTAMPTZ NOT NULL | Publication timestamp |
| `ingested_at` | TIMESTAMPTZ | Platform ingest timestamp |

**Indexes:** symbol_tickers (GIN), published_at, sentiment.
**Elasticsearch:** Synced to `news` index via CDC pipeline.

---

### screenerx.sentiment_data

**Purpose:** NLP-derived sentiment signals from multiple sources per symbol.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Signal identifier |
| `symbol_id` | UUID FK → symbols | Target instrument |
| `timestamp` | TIMESTAMPTZ NOT NULL | Signal timestamp |
| `source` | sentiment_source | news / twitter / reddit / analyst / options_flow / insider |
| `label` | sentiment_label | Sentiment direction |
| `score` | NUMERIC(5,4) | Quantified score in [-1.0, 1.0] |
| `sample_count` | INTEGER | Number of items this signal is derived from |
| `metadata` | JSONB | Source-specific context |

**Special notes:** TimescaleDB hypertable. Chunk: 7 days.

---

### screenerx.companies

**Purpose:** Company profile and fundamental overview per listed entity.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Company identifier |
| `symbol_id` | UUID FK → symbols UNIQUE | Corresponding symbol |
| `description` | TEXT | Business description |
| `website` | VARCHAR(255) | Corporate website |
| `sector` | VARCHAR(100) | GICS sector |
| `industry` | VARCHAR(200) | GICS industry |
| `country` | CHAR(2) | Registered country |
| `ceo` | VARCHAR(255) | Current CEO name |
| `employee_count` | INTEGER | Number of employees |
| `founded_date` | DATE | Company founding date |
| `headquarters` | VARCHAR(255) | City and country of HQ |
| `financials_summary` | JSONB | Latest financial highlights snapshot |

**Seed data:** 8 companies (Reliance, TCS, Infosys, HDFC Bank, Wipro, ICICI Bank, SBI, HCL Tech).

---

### screenerx.balance_sheets

**Purpose:** Quarterly and annual balance sheet filings.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Filing identifier |
| `symbol_id` | UUID FK → symbols | Reporting company |
| `period` | period_type | Q1 / Q2 / Q3 / Q4 / Annual |
| `fiscal_year` | VARCHAR(10) | e.g. FY2025 |
| `report_date` | DATE | Filing date |
| `total_assets` | NUMERIC(18,2) | Total assets (INR crore) |
| `total_liabilities` | NUMERIC(18,2) | Total liabilities |
| `equity` | NUMERIC(18,2) | Shareholders equity |
| `cash` | NUMERIC(18,2) | Cash and cash equivalents |
| `debt` | NUMERIC(18,2) | Total borrowings |
| `current_assets` | NUMERIC(18,2) | Current assets |
| `current_liabilities` | NUMERIC(18,2) | Current liabilities |
| `inventory` | NUMERIC(18,2) | Inventory value |
| `receivables` | NUMERIC(18,2) | Trade receivables |

---

### screenerx.income_statements

**Purpose:** Quarterly and annual profit & loss statements.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Filing identifier |
| `symbol_id` | UUID FK → symbols | Reporting company |
| `period` | period_type | Period classification |
| `fiscal_year` | VARCHAR(10) | Fiscal year |
| `report_date` | DATE | Filing date |
| `revenue` | NUMERIC(18,2) | Net revenue / sales |
| `gross_profit` | NUMERIC(18,2) | Revenue minus COGS |
| `operating_profit` | NUMERIC(18,2) | EBIT |
| `net_profit` | NUMERIC(18,2) | PAT |
| `ebitda` | NUMERIC(18,2) | EBITDA |
| `interest` | NUMERIC(18,2) | Finance costs |
| `tax` | NUMERIC(18,2) | Income tax expense |
| `eps` | NUMERIC(18,4) | Basic EPS |
| `diluted_eps` | NUMERIC(18,4) | Diluted EPS |

---

### screenerx.cash_flows

**Purpose:** Quarterly and annual cash flow statements.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Filing identifier |
| `symbol_id` | UUID FK → symbols | Reporting company |
| `period` | period_type | Period classification |
| `fiscal_year` | VARCHAR(10) | Fiscal year |
| `report_date` | DATE | Filing date |
| `operating_cf` | NUMERIC(18,2) | Operating cash flow |
| `investing_cf` | NUMERIC(18,2) | Investing cash flow |
| `financing_cf` | NUMERIC(18,2) | Financing cash flow |
| `free_cf` | NUMERIC(18,2) | Free cash flow (operating - capex) |
| `capex` | NUMERIC(18,2) | Capital expenditure |
| `dividends_paid` | NUMERIC(18,2) | Cash dividends paid |

---

### screenerx.financial_ratios

**Purpose:** Pre-computed daily financial ratios per symbol (avoids expensive joins at query time).

| Column | Type | Description |
|---|---|---|
| `symbol_id` | UUID FK → symbols | Instrument |
| `as_of_date` | DATE NOT NULL | Ratio computation date |
| `pe_ratio` | NUMERIC | Price-to-Earnings |
| `pb_ratio` | NUMERIC | Price-to-Book |
| `ps_ratio` | NUMERIC | Price-to-Sales |
| `ev_ebitda` | NUMERIC | EV/EBITDA |
| `roe` | NUMERIC | Return on Equity % |
| `roa` | NUMERIC | Return on Assets % |
| `roce` | NUMERIC | Return on Capital Employed % |
| `debt_equity` | NUMERIC | Debt-to-Equity ratio |
| `current_ratio` | NUMERIC | Current ratio |
| `dividend_yield` | NUMERIC | Dividend yield % |
| `market_cap` | NUMERIC(18,2) | Market capitalisation |
| `enterprise_value` | NUMERIC(18,2) | Enterprise value |

**Special notes:** TimescaleDB hypertable. Chunk: 3 months. Primary key: (symbol_id, as_of_date).

---

### screenerx.shareholding_patterns

**Purpose:** Quarterly shareholding pattern filings per instrument.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Filing identifier |
| `symbol_id` | UUID FK → symbols | Instrument |
| `quarter_end` | DATE NOT NULL | Quarter end date |
| `promoter_pct` | NUMERIC | Promoter holding % |
| `fii_pct` | NUMERIC | Foreign institutional % |
| `dii_pct` | NUMERIC | Domestic institutional % |
| `public_pct` | NUMERIC | Public / retail % |
| `pledge_pct` | NUMERIC | Pledged shares % |

---

### screenerx.mutual_fund_holdings

**Purpose:** Mutual fund holdings disclosures per symbol per quarter.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Holding record ID |
| `symbol_id` | UUID FK → symbols | Held instrument |
| `fund_name` | VARCHAR(255) NOT NULL | Fund scheme name |
| `amc` | VARCHAR(100) | Asset management company |
| `quarter_end` | DATE NOT NULL | Quarter end date |
| `holding_pct` | NUMERIC | % of fund AUM in this stock |
| `shares_held` | BIGINT | Number of shares held |
| `value` | NUMERIC(18,2) | Market value of holding |

---

### screenerx.institutional_holdings

**Purpose:** FII, DII, insurance, pension fund, and hedge fund holdings disclosures.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Holding record ID |
| `symbol_id` | UUID FK → symbols | Held instrument |
| `inst_type` | institution_type | fii / dii / insurance / bank / mf / hedge_fund / pension_fund |
| `institution_name` | VARCHAR(255) | Institution name |
| `quarter_end` | DATE NOT NULL | Quarter end date |
| `holding_pct` | NUMERIC | % of total outstanding |
| `shares_held` | BIGINT | Shares held |
| `value` | NUMERIC(18,2) | Market value |

---

### screenerx.analyst_ratings

**Purpose:** Sell-side analyst ratings and price targets per symbol.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Rating record ID |
| `symbol_id` | UUID FK → symbols | Covered instrument |
| `analyst_firm` | VARCHAR(100) NOT NULL | Research firm name |
| `analyst_name` | VARCHAR(100) | Individual analyst |
| `rating` | analyst_rating | strong_buy / buy / hold / sell / strong_sell / not_rated |
| `target_price` | NUMERIC(18,2) | 12-month price target |
| `rating_date` | DATE NOT NULL | Date of rating |
| `rationale` | TEXT | Rating justification |
| `previous_rating` | analyst_rating | Previous rating (for change tracking) |
| `previous_target` | NUMERIC(18,2) | Previous target price |

---

### screenerx.screener_templates

**Purpose:** Public and user-authored screener filter templates.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Template identifier |
| `created_by` | UUID FK → shared.users | Author |
| `name` | VARCHAR(255) NOT NULL | Template name |
| `description` | TEXT | What the screener looks for |
| `category` | VARCHAR(100) | Template category (value, growth, momentum, etc.) |
| `is_public` | BOOLEAN | Visible to all users |
| `usage_count` | INTEGER | Number of times cloned / used |
| `tags` | TEXT[] | Topic tags |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last update |

---

### screenerx.screener_filters

**Purpose:** Individual filter conditions belonging to a screener template.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Filter identifier |
| `screener_id` | UUID FK → screener_templates | Parent template |
| `field` | VARCHAR(100) NOT NULL | Data field to filter on (e.g. pe_ratio, market_cap) |
| `operator` | filter_operator | gt / lt / gte / lte / eq / neq / in / between / etc. |
| `value` | JSONB NOT NULL | Filter value(s) |
| `conjunction` | VARCHAR(5) | AND / OR grouping |
| `sort_order` | INTEGER | Display and evaluation order |

---

### screenerx.saved_screeners

**Purpose:** User-personalised saved screeners with custom filter overrides.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Saved screener identifier |
| `user_id` | UUID FK → shared.users | Owner |
| `template_id` | UUID FK → screener_templates | Based-on template (nullable) |
| `name` | VARCHAR(255) NOT NULL | Screener name |
| `filters` | JSONB NOT NULL | Full filter configuration |
| `is_favourite` | BOOLEAN | Pinned to user dashboard |
| `last_run_at` | TIMESTAMPTZ | Most recent execution timestamp |
| `run_count` | INTEGER | Total number of executions |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

---

### screenerx.screener_results_cache

**Purpose:** Persisted screener result sets for result deduplication and history.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Cache record ID |
| `screener_id` | UUID FK → saved_screeners | Source screener |
| `filter_hash` | VARCHAR(64) | SHA-256 of normalised filter JSON |
| `result_symbol_ids` | JSONB NOT NULL | Array of matching symbol UUIDs |
| `result_count` | INTEGER | Number of results |
| `executed_at` | TIMESTAMPTZ NOT NULL | Execution timestamp |
| `execution_ms` | INTEGER | Execution duration in ms |

---

### screenerx.screener_executions

**Purpose:** Audit log of every screener run with performance metrics.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Execution log ID |
| `user_id` | UUID FK → shared.users | User who ran the screener |
| `screener_id` | UUID FK → saved_screeners | Screener executed |
| `result_count` | INTEGER | Number of matching symbols |
| `execution_ms` | INTEGER | Total execution duration |
| `cache_hit` | BOOLEAN | Whether result came from cache |
| `executed_at` | TIMESTAMPTZ NOT NULL | Execution timestamp |

---

### screenerx.custom_formulas

**Purpose:** User-defined calculated fields for use in screener filters and column sets.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Formula identifier |
| `user_id` | UUID FK → shared.users | Formula author |
| `name` | VARCHAR(100) NOT NULL | Formula name |
| `expression` | TEXT NOT NULL | Mathematical or logical expression |
| `description` | TEXT | What this formula computes |
| `return_type` | VARCHAR(20) | numeric / boolean / text |
| `is_public` | BOOLEAN | Visible to other users |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

---

### screenerx.portfolios

**Purpose:** Investment portfolio containers — real, paper-trading, or model portfolios.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Portfolio identifier |
| `user_id` | UUID FK → shared.users | Owner |
| `tenant_id` | UUID NOT NULL | Owning tenant |
| `name` | VARCHAR(255) NOT NULL | Portfolio name |
| `description` | TEXT | Description |
| `currency` | CHAR(3) | Base currency |
| `benchmark_symbol` | VARCHAR(50) | Benchmark ticker for comparison (e.g. NIFTY50) |
| `portfolio_type` | portfolio_type | real / paper / model |
| `broker_account_id` | UUID | Linked broker account (nullable) |
| `is_active` | BOOLEAN | Whether portfolio is active |
| `inception_date` | DATE | Performance calculation start date |

**Relationships:** Referenced by quantnova.orders, portfolio_positions, portfolio_transactions, portfolio_snapshots, portfolio_performance, goals, rebalancing_rules.
**Special notes:** RLS enabled. Unique constraint on (user_id, name).

---

### screenerx.portfolio_positions

**Purpose:** Current holdings per symbol in each portfolio.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Position record |
| `portfolio_id` | UUID FK → portfolios | Parent portfolio |
| `symbol_id` | UUID FK → symbols | Held instrument |
| `quantity` | NUMERIC(18,6) NOT NULL | Current holding quantity |
| `avg_cost` | NUMERIC(18,6) | Average cost per unit |
| `current_price` | NUMERIC(18,6) | Last updated price |
| `unrealised_pnl` | NUMERIC(18,2) | Unrealised profit/loss |
| `unrealised_pnl_pct` | NUMERIC | P&L as percentage |
| `updated_at` | TIMESTAMPTZ | Last price/position update |

**Indexes:** portfolio_id, symbol_id; unique on (portfolio_id, symbol_id).

---

### screenerx.portfolio_transactions

**Purpose:** Immutable transaction ledger for all portfolio activity.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Transaction identifier |
| `portfolio_id` | UUID FK → portfolios | Parent portfolio |
| `symbol_id` | UUID FK → symbols | Instrument transacted |
| `txn_type` | transaction_type | buy / sell / dividend / split / bonus / transfer_in / transfer_out / interest / fee |
| `quantity` | NUMERIC(18,6) NOT NULL | Transacted quantity |
| `price` | NUMERIC(18,6) | Transaction price per unit |
| `brokerage` | NUMERIC(18,2) | Brokerage charges |
| `taxes` | NUMERIC(18,2) | STT, GST, stamp duty, etc. |
| `net_amount` | NUMERIC(18,2) | Total transaction value |
| `transaction_date` | DATE NOT NULL | Settlement date |
| `notes` | TEXT | Optional transaction notes |

---

### screenerx.portfolio_snapshots

**Purpose:** End-of-day portfolio valuation snapshots.

| Column | Type | Description |
|---|---|---|
| `portfolio_id` | UUID FK → portfolios | Portfolio |
| `snapshot_date` | DATE NOT NULL | EOD date |
| `total_value` | NUMERIC(18,2) | Portfolio market value |
| `invested_value` | NUMERIC(18,2) | Total cost basis |
| `total_pnl` | NUMERIC(18,2) | Total P&L (realised + unrealised) |
| `day_pnl` | NUMERIC(18,2) | Single-day P&L |
| `day_pnl_pct` | NUMERIC | Single-day return % |
| `positions_snapshot` | JSONB | Full position state as of EOD |

**Special notes:** TimescaleDB hypertable. Chunk: 3 months. PK: (portfolio_id, snapshot_date).

---

### screenerx.portfolio_performance

**Purpose:** Daily performance metrics with risk-adjusted return statistics.

| Column | Type | Description |
|---|---|---|
| `portfolio_id` | UUID FK → portfolios | Portfolio |
| `date` | DATE NOT NULL | Measurement date |
| `daily_return` | NUMERIC | Daily return % |
| `cumulative_return` | NUMERIC | Total return since inception % |
| `benchmark_return` | NUMERIC | Benchmark cumulative return % |
| `alpha` | NUMERIC | Jensen's alpha |
| `beta` | NUMERIC | Portfolio beta vs benchmark |
| `sharpe_ratio` | NUMERIC | Rolling Sharpe ratio |
| `sortino_ratio` | NUMERIC | Rolling Sortino ratio |
| `max_drawdown` | NUMERIC | Max drawdown from peak |
| `volatility` | NUMERIC | Annualised volatility |

**Special notes:** TimescaleDB hypertable. Chunk: 3 months. PK: (portfolio_id, date).

---

### screenerx.watchlists

**Purpose:** Named watchlists per user for grouping instruments of interest.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Watchlist identifier |
| `user_id` | UUID FK → shared.users | Owner |
| `name` | VARCHAR(100) NOT NULL | Watchlist name |
| `description` | TEXT | Optional description |
| `is_default` | BOOLEAN | TRUE = shown on user home screen |
| `is_public` | BOOLEAN | Shared publicly |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last modification |

**Seed data:** 4 watchlists.

---

### screenerx.watchlist_items

**Purpose:** Symbols within a watchlist, with ordering and personal notes.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Item identifier |
| `watchlist_id` | UUID FK → watchlists | Parent watchlist |
| `symbol_id` | UUID FK → symbols | Instrument |
| `sort_order` | INTEGER | Display order position |
| `notes` | JSONB | Personal notes (alerts, targets) |
| `added_at` | TIMESTAMPTZ | When item was added |

**Special notes:** Unique constraint on (watchlist_id, symbol_id). Redis sorted set mirrors this for O(log N) retrieval.

---

### screenerx.goals

**Purpose:** Financial goal tracking linked to portfolios (retirement, education, etc.).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Goal identifier |
| `user_id` | UUID FK → shared.users | Goal owner |
| `portfolio_id` | UUID FK → portfolios | Linked funding portfolio |
| `name` | VARCHAR(255) NOT NULL | Goal name |
| `goal_type` | goal_type | retirement / education / house / emergency / travel / custom |
| `status` | goal_status | active / completed / paused / cancelled |
| `target_amount` | NUMERIC(18,2) NOT NULL | Target corpus |
| `current_amount` | NUMERIC(18,2) | Current value towards goal |
| `target_date` | DATE | Deadline |
| `sip_amount` | NUMERIC(18,2) | Monthly SIP amount |
| `created_at` | TIMESTAMPTZ | Goal creation timestamp |

---

### screenerx.rebalancing_rules

**Purpose:** Automatic rebalancing rules for portfolio target-weight enforcement.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Rule identifier |
| `portfolio_id` | UUID FK → portfolios | Target portfolio |
| `rule_type` | rebalancing_rule_type | target_weight / threshold / calendar |
| `target_weights` | JSONB | Map of symbol_id → target % |
| `threshold_pct` | NUMERIC | Drift threshold before rebalancing |
| `calendar_frequency` | VARCHAR(20) | Monthly / quarterly / annually |
| `next_rebalance_date` | DATE | Next scheduled rebalance |
| `is_active` | BOOLEAN | Rule active status |

---

### screenerx.alerts

**Purpose:** User-configured price, volume, technical, and fundamental alerts.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Alert identifier |
| `user_id` | UUID FK → shared.users | Alert owner |
| `symbol_id` | UUID FK → symbols | Monitored instrument |
| `alert_type` | alert_type | price / volume / technical / fundamental / news / custom / earnings / insider |
| `name` | VARCHAR(255) | Alert name |
| `condition` | JSONB NOT NULL | Condition expression (field, operator, value) |
| `is_active` | BOOLEAN | Alert enabled state |
| `cooldown_seconds` | INTEGER | Minimum seconds between triggers |
| `notification_channels` | notification_channel[] | Channels to notify on trigger |
| `last_triggered_at` | TIMESTAMPTZ | Most recent trigger timestamp |
| `created_at` | TIMESTAMPTZ | Alert creation timestamp |

---

### screenerx.alert_events

**Purpose:** Immutable log of every alert trigger event.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Event identifier |
| `alert_id` | UUID FK → alerts | Triggered alert |
| `symbol_id` | UUID FK → symbols | Symbol that triggered the alert |
| `triggered_at` | TIMESTAMPTZ NOT NULL | Trigger timestamp |
| `trigger_value` | NUMERIC | Value that caused the trigger |
| `condition_snapshot` | JSONB | Alert condition at time of trigger |
| `context` | JSONB | Market context snapshot |
| `notification_sent` | BOOLEAN | Whether notification was dispatched |

**Special notes:** TimescaleDB hypertable. Chunk: 14 days.

---

### screenerx.websocket_sessions

**Purpose:** Active WebSocket connections with their symbol subscriptions.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | WS session identifier |
| `user_id` | UUID FK → shared.users | Connected user |
| `connection_id` | VARCHAR(100) UNIQUE NOT NULL | Gateway-assigned connection ID |
| `subscribed_symbols` | TEXT[] | Array of subscribed symbol IDs |
| `subscribed_channels` | TEXT[] | Additional channel subscriptions |
| `connected_at` | TIMESTAMPTZ | Connection establishment time |
| `last_ping_at` | TIMESTAMPTZ | Last keep-alive ping |

---

### screenerx.kpi_metrics

**Purpose:** Platform-level KPI time series (DAU, screener runs, alerts fired, etc.).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Metric record |
| `metric_date` | DATE NOT NULL | Measurement date |
| `metric_name` | VARCHAR(100) NOT NULL | KPI name |
| `value` | NUMERIC NOT NULL | Metric value |
| `dimensions` | JSONB | Dimensional breakdown (e.g. by exchange, by plan) |

**Special notes:** TimescaleDB hypertable. Chunk: 1 month.

---

### screenerx.user_activity

**Purpose:** Behavioural event log for analytics and personalisation.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Event identifier |
| `user_id` | UUID FK → shared.users | Acting user |
| `action` | VARCHAR(100) NOT NULL | Action performed (view_symbol, run_screener, etc.) |
| `entity_type` | VARCHAR(50) | Entity type acted upon |
| `entity_id` | UUID | Entity identifier |
| `session_id` | UUID | Session at time of action |
| `metadata` | JSONB | Action context |
| `created_at` | TIMESTAMPTZ NOT NULL | Event timestamp |

**Special notes:** TimescaleDB hypertable. Chunk: 7 days.

---

### screenerx.search_logs

**Purpose:** Full-text search query log for analytics and autocomplete improvement.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Log entry identifier |
| `user_id` | UUID FK → shared.users | Searching user (nullable for anonymous) |
| `query` | TEXT NOT NULL | Raw search query |
| `result_count` | INTEGER | Number of results returned |
| `response_ms` | INTEGER | Response time in milliseconds |
| `top_result_id` | UUID | UUID of the first result clicked |
| `searched_at` | TIMESTAMPTZ NOT NULL | Search timestamp |

---

### screenerx.market_indices

**Purpose:** Daily snapshots of domestic and global market indices with sparkline JSON arrays for dashboard mini-charts. Added in v1.1.0.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Record identifier |
| `symbol` | VARCHAR(50) NOT NULL | Index ticker (NIFTY, SENSEX, SPX, etc.) |
| `name` | VARCHAR(200) NOT NULL | Full display name |
| `region` | VARCHAR(100) | Geographic region (India / USA / UK / Japan / etc.) |
| `index_type` | VARCHAR(20) | `domestic` / `global` / `sector` / `vix` |
| `current_value` | DECIMAL(18,2) NOT NULL | Current index level |
| `change_value` | DECIMAL(18,2) NOT NULL | Absolute change from previous close |
| `change_pct` | DECIMAL(8,4) NOT NULL | Percentage change |
| `prev_close` | DECIMAL(18,2) NOT NULL | Previous session closing value |
| `open_value` | DECIMAL(18,2) | Opening value for the day |
| `high_value` | DECIMAL(18,2) | Day high |
| `low_value` | DECIMAL(18,2) | Day low |
| `sparkline` | JSONB | Array of recent values (12 points) for mini sparkline chart |
| `trade_date` | DATE | Snapshot date — unique per (symbol, trade_date) |
| `is_active` | BOOLEAN | Whether to show in the dashboard |
| `sort_order` | INTEGER | Display ordering |

**Unique constraint:** `(symbol, trade_date)` — one snapshot per index per day.
**Indexes:** symbol, trade_date DESC, index_type.

---

### screenerx.fii_dii_activity

**Purpose:** Daily FII (Foreign Institutional Investor) and DII (Domestic Institutional Investor) buy/sell activity in crore INR, used for the FII/DII dashboard panel. Added in v1.1.0.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Record identifier |
| `activity_date` | DATE NOT NULL | Trading date |
| `fii_buy` | DECIMAL(18,2) NOT NULL | FII gross purchases (₹ Crore) |
| `fii_sell` | DECIMAL(18,2) NOT NULL | FII gross sales (₹ Crore) |
| `fii_net` | DECIMAL(18,2) | **Generated column** — fii_buy − fii_sell |
| `dii_buy` | DECIMAL(18,2) NOT NULL | DII gross purchases (₹ Crore) |
| `dii_sell` | DECIMAL(18,2) NOT NULL | DII gross sales (₹ Crore) |
| `dii_net` | DECIMAL(18,2) | **Generated column** — dii_buy − dii_sell |
| `segment` | VARCHAR(20) | `equity` / `debt` / `hybrid` |
| `source` | VARCHAR(100) | Data source (default: NSE) |

**Unique constraint:** `(activity_date, segment)` — one row per day per segment.
**Indexes:** activity_date DESC.
**Note:** `fii_net` and `dii_net` are PostgreSQL `GENERATED ALWAYS AS ... STORED` columns — they cannot be set manually.

---

### screenerx.ipos

**Purpose:** IPO tracker covering the full lifecycle from upcoming announcement through listing. Includes GMP (Grey Market Premium) and subscription data. Added in v1.1.0.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Record identifier |
| `company_name` | VARCHAR(500) NOT NULL | Issuer company name |
| `ticker` | VARCHAR(50) | Post-listing exchange symbol |
| `exchange` | VARCHAR(20) | Listing exchange (NSE / BSE) |
| `issue_size_cr` | DECIMAL(18,2) | Total issue size in ₹ Crore |
| `price_band_low` | DECIMAL(10,2) | Lower bound of price band |
| `price_band_high` | DECIMAL(10,2) | Upper bound of price band |
| `lot_size` | INTEGER | Minimum retail application lot |
| `open_date` | DATE | Subscription opens |
| `close_date` | DATE | Subscription closes |
| `allotment_date` | DATE | Allotment announcement date |
| `listing_date` | DATE | Exchange listing date |
| `listing_price` | DECIMAL(10,2) | Actual listing price (NULL until listed) |
| `gmp` | DECIMAL(10,2) | Grey Market Premium in ₹ |
| `status` | VARCHAR(20) | `upcoming` / `open` / `closed` / `listed` / `withdrawn` |
| `category` | VARCHAR(50) | Industry/sector category |
| `registrar` | VARCHAR(200) | Registrar company name |
| `subscription_times` | DECIMAL(8,2) | Overall subscription multiple (filled post-close) |
| `min_investment` | DECIMAL(10,2) | Minimum investment amount in ₹ |

**Indexes:** status, open_date, listing_date.

---

## quantnova schema

### quantnova.brokers

**Purpose:** Registered broker integrations on the platform.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Broker identifier |
| `name` | VARCHAR(100) UNIQUE NOT NULL | Broker name (e.g. Zerodha, Upstox) |
| `code` | VARCHAR(20) UNIQUE NOT NULL | Short code |
| `api_base_url` | TEXT | REST API base URL |
| `supports_intraday` | BOOLEAN | Intraday trading support |
| `supports_options` | BOOLEAN | F&O trading support |
| `supports_algo` | BOOLEAN | Algorithmic order support |
| `is_active` | BOOLEAN | Available for new accounts |
| `config` | JSONB | Broker-specific API configuration |

**Seed data:** 5 brokers (Zerodha, Upstox, Angel Broking, HDFC Securities, ICICI Direct).

---

### quantnova.broker_accounts

**Purpose:** User-linked brokerage accounts.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Account identifier |
| `user_id` | UUID FK → shared.users | Account owner |
| `broker_id` | UUID FK → brokers | Linked broker |
| `account_type` | account_type | demat / trading / commodity / currency / mutual_fund |
| `account_number` | VARCHAR(50) NOT NULL | Broker account number |
| `is_active` | BOOLEAN | Account active status |
| `available_margin` | NUMERIC(18,2) | Available margin balance |
| `used_margin` | NUMERIC(18,2) | Margin in use |
| `api_access_token` | TEXT | Encrypted OAuth token for broker API |

---

### quantnova.orders

**Purpose:** Complete order lifecycle records for all trading activity.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Order identifier |
| `user_id` | UUID FK → shared.users | Placing user |
| `portfolio_id` | UUID FK → screenerx.portfolios | Associated portfolio |
| `broker_account_id` | UUID FK → broker_accounts | Routing account |
| `symbol_id` | UUID FK → screenerx.symbols | Traded instrument |
| `order_type` | order_type | market / limit / stop / stop_limit / bracket / cover / trailing_stop |
| `side` | order_side | buy / sell |
| `quantity` | NUMERIC(18,6) NOT NULL | Order quantity |
| `price` | NUMERIC(18,6) | Limit price (required for limit/stop_limit) |
| `trigger_price` | NUMERIC(18,6) | Trigger price (required for stop/stop_limit) |
| `disclosed_qty` | NUMERIC(18,6) | Iceberg visible quantity |
| `product_type` | product_type | intraday / delivery / futures / options / currency / commodity |
| `status` | order_status | pending / open / partial / filled / cancelled / rejected / expired |
| `broker_order_id` | VARCHAR(100) | Broker-assigned order ID |
| `exchange_order_id` | VARCHAR(100) | Exchange-assigned order ID |
| `parent_order_id` | UUID FK → orders | For bracket/cover order legs |
| `validity` | order_validity | day / ioc / gtc / gtd / amo |
| `placed_at` | TIMESTAMPTZ | Order submission timestamp |
| `executed_at` | TIMESTAMPTZ | Full execution timestamp |
| `cancelled_at` | TIMESTAMPTZ | Cancellation timestamp |

**Special notes:** Cross-schema FK to screenerx.symbols and screenerx.portfolios.

---

### quantnova.order_fills

**Purpose:** Partial fill records for orders executed in multiple tranches.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Fill identifier |
| `order_id` | UUID FK → orders | Parent order |
| `filled_qty` | NUMERIC(18,6) NOT NULL | Quantity filled in this tranche |
| `fill_price` | NUMERIC(18,6) NOT NULL | Execution price |
| `brokerage` | NUMERIC(18,2) | Brokerage for this fill |
| `taxes` | NUMERIC(18,2) | STT + other taxes |
| `exchange_fill_id` | VARCHAR(100) | Exchange trade ID |
| `filled_at` | TIMESTAMPTZ NOT NULL | Fill timestamp |

---

### quantnova.executions

**Purpose:** Confirmed execution records from the broker/exchange.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Execution identifier |
| `order_id` | UUID FK → orders | Parent order |
| `broker_account_id` | UUID FK → broker_accounts | Executing account |
| `exchange_execution_id` | VARCHAR(100) UNIQUE | Exchange trade ID |
| `executed_qty` | NUMERIC(18,6) NOT NULL | Total executed quantity |
| `executed_price` | NUMERIC(18,6) NOT NULL | Average execution price |
| `total_charges` | NUMERIC(18,2) | All-in charges (brokerage + taxes) |
| `executed_at` | TIMESTAMPTZ NOT NULL | Exchange execution timestamp |

---

### quantnova.positions

**Purpose:** Current open positions per user per broker account.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Position identifier |
| `user_id` | UUID FK → shared.users | Position holder |
| `broker_account_id` | UUID FK → broker_accounts | Account holding position |
| `symbol_id` | UUID FK → screenerx.symbols | Instrument |
| `net_qty` | NUMERIC(18,6) NOT NULL | Net holding (positive = long) |
| `avg_price` | NUMERIC(18,6) | Average entry price |
| `buy_qty` | NUMERIC(18,6) | Total bought today |
| `sell_qty` | NUMERIC(18,6) | Total sold today |
| `realised_pnl` | NUMERIC(18,2) | Realised P&L today |
| `unrealised_pnl` | NUMERIC(18,2) | Unrealised P&L at last price |
| `product_type` | product_type | Position product type |
| `position_date` | DATE | Date position was opened |

**Indexes:** (user_id, symbol_id, position_date), broker_account_id.

---

### quantnova.risk_limits

**Purpose:** Per-user risk controls that the order management system enforces.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Risk limit identifier |
| `user_id` | UUID FK → shared.users | Subject user |
| `limit_type` | risk_limit_type | max_position_size / max_daily_loss / max_drawdown / sector_concentration / var / max_leverage |
| `limit_value` | NUMERIC NOT NULL | Limit threshold value |
| `on_breach` | breach_action | alert / block / liquidate |
| `is_active` | BOOLEAN | Limit enforcement active |
| `scope` | JSONB | Optional scope (e.g. specific symbol or sector) |

---

### quantnova.pnl_snapshots

**Purpose:** Intraday P&L snapshots per user per broker account.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Snapshot identifier |
| `user_id` | UUID FK → shared.users | User |
| `broker_account_id` | UUID FK → broker_accounts | Account |
| `timestamp` | TIMESTAMPTZ NOT NULL | Snapshot time |
| `realised_pnl` | NUMERIC(18,2) | Cumulative realised P&L |
| `unrealised_pnl` | NUMERIC(18,2) | Mark-to-market unrealised P&L |
| `total_pnl` | NUMERIC(18,2) | realised + unrealised |
| `day_high` | NUMERIC(18,2) | Peak total P&L today |
| `day_low` | NUMERIC(18,2) | Trough total P&L today |

**Special notes:** TimescaleDB hypertable. Chunk: 1 day.

---

### quantnova.strategies

**Purpose:** Algorithmic trading strategy definitions.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Strategy identifier |
| `user_id` | UUID FK → shared.users | Strategy author |
| `name` | VARCHAR(255) NOT NULL | Strategy name |
| `strategy_type` | strategy_type | momentum / mean_reversion / arbitrage / ml / manual / factor / pairs_trading / statistical_arb |
| `description` | TEXT | Strategy description |
| `is_active` | BOOLEAN | Strategy enabled |
| `is_live` | BOOLEAN | TRUE = live trading, FALSE = paper |
| `parameters` | JSONB | Strategy parameter set (current) |
| `universe` | JSONB | Symbol universe filter |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

**Seed data:** 3 trading strategies.

---

### quantnova.strategy_versions

**Purpose:** Version history of strategy code and parameters.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Version identifier |
| `strategy_id` | UUID FK → strategies | Parent strategy |
| `version_number` | INTEGER NOT NULL | Sequential version number |
| `code_snapshot` | TEXT | Code at this version |
| `parameters` | JSONB | Parameters at this version |
| `change_notes` | TEXT | Description of changes |
| `created_by` | UUID | Author of this version |
| `created_at` | TIMESTAMPTZ | Version creation timestamp |

---

### quantnova.backtests

**Purpose:** Backtest run configurations and status.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Backtest identifier |
| `strategy_id` | UUID FK → strategies | Tested strategy |
| `strategy_version_id` | UUID FK → strategy_versions | Specific version |
| `user_id` | UUID FK → shared.users | Initiating user |
| `start_date` | DATE NOT NULL | Backtest period start |
| `end_date` | DATE NOT NULL | Backtest period end |
| `status` | backtest_status | queued / running / completed / failed / cancelled |
| `initial_capital` | NUMERIC(18,2) | Starting capital |
| `universe` | JSONB | Symbol universe for this run |
| `parameters` | JSONB | Parameter overrides for this run |
| `error_message` | TEXT | Failure reason |
| `queued_at` | TIMESTAMPTZ | When queued |
| `started_at` | TIMESTAMPTZ | Execution start |
| `completed_at` | TIMESTAMPTZ | Execution completion |

---

### quantnova.backtest_results

**Purpose:** Performance metrics and trade logs from completed backtests.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Results record |
| `backtest_id` | UUID FK → backtests UNIQUE | Parent backtest |
| `total_return` | NUMERIC | Total return % over backtest period |
| `annualised_return` | NUMERIC | Annualised return % |
| `sharpe_ratio` | NUMERIC | Sharpe ratio |
| `sortino_ratio` | NUMERIC | Sortino ratio |
| `max_drawdown` | NUMERIC | Maximum drawdown % |
| `win_rate` | NUMERIC | % of trades that were profitable |
| `total_trades` | INTEGER | Total trade count |
| `profit_factor` | NUMERIC | Gross profit / gross loss |
| `calmar_ratio` | NUMERIC | Annualised return / max drawdown |
| `equity_curve` | JSONB | Daily portfolio value array |
| `trade_log` | JSONB | Array of individual trade records |

---

### quantnova.optimization_runs

**Purpose:** Strategy parameter grid-search / optimisation run records.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Optimisation run identifier |
| `strategy_id` | UUID FK → strategies | Strategy being optimised |
| `user_id` | UUID FK → shared.users | Run initiator |
| `parameter_grid` | JSONB NOT NULL | Parameter sweep configuration |
| `status` | run_status | pending / running / completed / failed / cancelled |
| `best_backtest_id` | UUID FK → backtests | Backtest with best metric |
| `best_parameters` | JSONB | Optimal parameter set |
| `optimization_metric` | VARCHAR(50) | Metric optimised (sharpe_ratio, total_return) |
| `started_at` | TIMESTAMPTZ | Run start |
| `completed_at` | TIMESTAMPTZ | Run completion |

---

### quantnova.alpha_signals

**Purpose:** Strategy-generated alpha signals (long, short, exit) per symbol per date.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Signal identifier |
| `strategy_id` | UUID FK → strategies | Generating strategy |
| `symbol_id` | UUID FK → screenerx.symbols | Target instrument |
| `signal_date` | DATE NOT NULL | Signal date |
| `signal_type` | signal_type | long / short / exit / scale_in / scale_out |
| `strength` | NUMERIC | Signal strength [0.0, 1.0] |
| `confidence` | NUMERIC | Model confidence [0.0, 1.0] |
| `target_price` | NUMERIC(18,6) | Price target |
| `stop_loss` | NUMERIC(18,6) | Stop-loss level |
| `metadata` | JSONB | Additional signal context |

**Special notes:** TimescaleDB hypertable. Chunk: 1 month.

---

### quantnova.ml_models

**Purpose:** Machine learning model registry.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Model identifier |
| `user_id` | UUID FK → shared.users | Model author |
| `name` | VARCHAR(255) NOT NULL | Model name |
| `model_type` | ml_model_type | classification / regression / clustering / nlp / rl / time_series / anomaly_detection |
| `description` | TEXT | Model purpose and approach |
| `is_active` | BOOLEAN | Whether model is available for deployment |
| `tags` | TEXT[] | Model topic tags |
| `created_at` | TIMESTAMPTZ | Registry entry creation |

---

### quantnova.model_versions

**Purpose:** Version history for ML models with artifact references and metrics.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Version identifier |
| `model_id` | UUID FK → ml_models | Parent model |
| `version_number` | INTEGER NOT NULL | Sequential version number |
| `framework` | VARCHAR(50) | scikit-learn / PyTorch / TensorFlow / XGBoost |
| `model_artifact_path` | TEXT | S3 / GCS artifact URI |
| `hyperparameters` | JSONB | Model hyperparameters |
| `metrics` | JSONB | Evaluation metrics (accuracy, AUC, RMSE, etc.) |
| `is_deployed` | BOOLEAN | Currently serving inference requests |
| `trained_at` | TIMESTAMPTZ | Training completion timestamp |
| `deployed_at` | TIMESTAMPTZ | Deployment timestamp |

---

### quantnova.feature_store

**Purpose:** Feature catalogue — definitions of all ML input features.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Feature identifier |
| `name` | VARCHAR(100) UNIQUE NOT NULL | Feature name |
| `description` | TEXT | What the feature measures |
| `data_type` | VARCHAR(20) | numeric / boolean / categorical |
| `computation_logic` | TEXT | SQL or Python snippet for computation |
| `source_tables` | TEXT[] | Source tables used in computation |
| `is_active` | BOOLEAN | Feature available for model training |
| `created_at` | TIMESTAMPTZ | Feature registration date |

---

### quantnova.feature_values

**Purpose:** Historical feature value store for model training and inference.

| Column | Type | Description |
|---|---|---|
| `feature_id` | UUID FK → feature_store | Feature definition |
| `symbol_id` | UUID FK → screenerx.symbols | Target symbol |
| `as_of_date` | DATE NOT NULL | Feature value date |
| `value` | NUMERIC | Computed feature value |
| `metadata` | JSONB | Computation context |

**Special notes:** TimescaleDB hypertable. Chunk: 3 months. PK: (feature_id, symbol_id, as_of_date).

---

### quantnova.training_runs

**Purpose:** ML model training job records with data ranges and output metrics.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Training run identifier |
| `model_id` | UUID FK → ml_models | Model being trained |
| `model_version_id` | UUID FK → model_versions | Resulting model version |
| `status` | run_status | pending / running / completed / failed / cancelled |
| `training_start_date` | DATE | Training data start date |
| `training_end_date` | DATE | Training data end date |
| `validation_start_date` | DATE | Validation data start |
| `validation_end_date` | DATE | Validation data end |
| `feature_ids` | JSONB | Array of feature UUIDs used |
| `metrics` | JSONB | Training and validation metrics |
| `started_at` | TIMESTAMPTZ | Job start timestamp |
| `completed_at` | TIMESTAMPTZ | Job completion timestamp |

---

### quantnova.inference_logs

**Purpose:** Audit trail of all ML model prediction requests (hypertable).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Inference record |
| `model_version_id` | UUID FK → model_versions | Serving model version |
| `symbol_id` | UUID FK → screenerx.symbols | Target symbol |
| `prediction` | recommendation_type | buy / sell / hold / watch / avoid |
| `confidence` | NUMERIC | Prediction confidence |
| `feature_snapshot` | JSONB | Input features used at inference time |
| `predicted_at` | TIMESTAMPTZ NOT NULL | Inference timestamp |

**Special notes:** TimescaleDB hypertable. Chunk: 7 days. Retained for 1 year.

---

### quantnova.ai_recommendations

**Purpose:** AI-generated investment recommendations surfaced to users.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Recommendation identifier |
| `user_id` | UUID FK → shared.users | Target user |
| `model_version_id` | UUID FK → model_versions | Generating model version |
| `symbol_id` | UUID FK → screenerx.symbols | Recommended instrument |
| `recommendation` | recommendation_type | buy / sell / hold / watch / avoid |
| `target_price` | NUMERIC(18,6) | AI-estimated price target |
| `confidence` | NUMERIC | Confidence score [0.0, 1.0] |
| `rationale` | TEXT | AI-generated explanation |
| `valid_until` | TIMESTAMPTZ | Recommendation expiry |
| `created_at` | TIMESTAMPTZ | Recommendation creation |

---

### quantnova.drift_detection

**Purpose:** Data and concept drift monitoring for deployed ML models.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Detection record |
| `model_version_id` | UUID FK → model_versions | Monitored model |
| `drift_type` | drift_type | data / concept / model / covariate |
| `drift_score` | NUMERIC NOT NULL | Computed drift magnitude |
| `threshold` | NUMERIC NOT NULL | Breach threshold |
| `breach_detected` | BOOLEAN | Whether threshold was exceeded |
| `affected_features` | TEXT[] | Features showing drift |
| `detection_date` | DATE NOT NULL | Detection date |
| `detected_at` | TIMESTAMPTZ | Detection timestamp |

---

### quantnova.event_store

**Purpose:** Immutable domain event log for all quantnova events (event sourcing pattern).

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Event identifier |
| `event_type` | VARCHAR(100) NOT NULL | Fully qualified event type (e.g. OrderPlaced, StrategyActivated) |
| `aggregate_id` | UUID NOT NULL | ID of the aggregate this event belongs to |
| `aggregate_type` | VARCHAR(100) NOT NULL | Aggregate class (Order, Strategy, Position, etc.) |
| `payload` | JSONB NOT NULL | Full event payload |
| `version` | INTEGER NOT NULL | Aggregate version at time of event |
| `occurred_at` | TIMESTAMPTZ NOT NULL | When event occurred |
| `caused_by_user_id` | UUID | User who triggered this event |
| `correlation_id` | UUID | Distributed trace correlation ID |

**Special notes:** TimescaleDB hypertable. Chunk: 7 days. Append-only — no UPDATE or DELETE.

---

## ndfl schema

### ndfl.tax_years

**Purpose:** Income tax filing records — one per user per assessment year.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Tax year record identifier |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `assessment_year` | VARCHAR(10) NOT NULL | e.g. 2024-25 |
| `financial_year_start` | DATE NOT NULL | e.g. 2023-04-01 |
| `financial_year_end` | DATE NOT NULL | e.g. 2024-03-31 |
| `filing_status` | filing_status_enum | not_started / in_progress / filed / revised / defective |
| `filing_deadline` | DATE | ITR filing deadline |
| `filed_at` | TIMESTAMPTZ | Actual filing timestamp |
| `acknowledgement_number` | VARCHAR(50) | ITR acknowledgement number |
| `itr_form_type` | itr_form_type_enum | ITR1 / ITR2 / ITR3 / ITR4 |
| `total_income` | NUMERIC(18,2) | Gross total income |
| `taxable_income` | NUMERIC(18,2) | Income after deductions |
| `total_tax` | NUMERIC(18,2) | Total tax liability |
| `tax_paid` | NUMERIC(18,2) | TDS + advance tax paid |
| `tax_refund` | NUMERIC(18,2) | Refund due (if tax_paid > total_tax) |
| `tax_payable` | NUMERIC(18,2) | Balance payable (if total_tax > tax_paid) |

**Special notes:** Unique constraint on (user_id, assessment_year).

---

### ndfl.income_sources

**Purpose:** Individual income head records for each tax year.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Income source record |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `income_head` | VARCHAR(50) NOT NULL | salary / house_property / business / capital_gains / other_sources |
| `source_name` | VARCHAR(255) | Employer / bank / company name |
| `pan_of_deductor` | VARCHAR(10) | PAN of income source |
| `gross_amount` | NUMERIC(18,2) NOT NULL | Gross income amount |
| `exemptions` | NUMERIC(18,2) | Applicable exemptions (HRA, LTA, etc.) |
| `deductions` | NUMERIC(18,2) | Standard deduction |
| `net_taxable` | NUMERIC(18,2) | Taxable amount for this head |
| `metadata` | JSONB | Head-specific attributes |

---

### ndfl.capital_gains

**Purpose:** Individual securities transaction records for capital gains computation.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Transaction record |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `asset_type` | VARCHAR(50) NOT NULL | equity / mutual_fund / property / gold / bond |
| `isin` | VARCHAR(12) | Security ISIN (for equity / MF) |
| `asset_name` | VARCHAR(255) NOT NULL | Security or asset name |
| `purchase_date` | DATE NOT NULL | Date of acquisition |
| `sale_date` | DATE NOT NULL | Date of disposal |
| `purchase_price` | NUMERIC(18,2) NOT NULL | Acquisition cost |
| `sale_price` | NUMERIC(18,2) NOT NULL | Sale consideration |
| `quantity` | NUMERIC(18,6) | Units sold |
| `indexed_cost` | NUMERIC(18,2) | Indexed cost of acquisition (LTCG) |
| `stcg` | NUMERIC(18,2) | Short-term capital gain |
| `ltcg` | NUMERIC(18,2) | Long-term capital gain |
| `is_equity` | BOOLEAN | TRUE = Section 112A rates apply |
| `brokerage` | NUMERIC(18,2) | Transaction charges |

---

### ndfl.tds_records

**Purpose:** Tax Deducted at Source records from Form 16 / Form 16A.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | TDS record identifier |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `deductor_name` | VARCHAR(255) NOT NULL | Name of TDS deductor |
| `deductor_tan` | VARCHAR(10) NOT NULL | TAN of deductor |
| `deductor_pan` | VARCHAR(10) | PAN of deductor |
| `section_code` | VARCHAR(10) NOT NULL | TDS section (192, 194, 194A, 194C, etc.) |
| `amount_paid` | NUMERIC(18,2) NOT NULL | Amount on which TDS was deducted |
| `tds_amount` | NUMERIC(18,2) NOT NULL | TDS amount deducted |
| `deduction_date` | DATE NOT NULL | Date of deduction / payment |
| `certificate_number` | VARCHAR(50) | Form 16 / 16A certificate number |

---

### ndfl.form26as

**Purpose:** Parsed Form 26AS data imported from the TRACES portal.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Record identifier |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `part` | VARCHAR(5) NOT NULL | Form 26AS part (A, B, C, D, etc.) |
| `deductor_name` | VARCHAR(255) | Deductor / collector name |
| `deductor_tan` | VARCHAR(10) | TAN |
| `total_amount_paid` | NUMERIC(18,2) | Total amount paid/credited |
| `total_tds` | NUMERIC(18,2) | Total TDS / TCS |
| `imported_at` | TIMESTAMPTZ | When this data was imported |
| `raw_data` | JSONB | Full parsed Form 26AS JSON |

---

### ndfl.tax_computations

**Purpose:** Computed tax liability with all deductions applied — one per tax year per user.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Computation record |
| `tax_year_id` | UUID FK → tax_years UNIQUE | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `gross_total_income` | NUMERIC(18,2) | Sum of all income heads |
| `deductions_80c` | NUMERIC(18,2) | Section 80C deductions (max 1.5L) |
| `deductions_80d` | NUMERIC(18,2) | Section 80D health insurance premium |
| `deductions_80ccd` | NUMERIC(18,2) | NPS contribution deduction |
| `deductions_other` | NUMERIC(18,2) | Other Chapter VI-A deductions |
| `total_deductions` | NUMERIC(18,2) | Total Chapter VI-A deductions |
| `net_taxable_income` | NUMERIC(18,2) | Gross income minus total deductions |
| `basic_tax` | NUMERIC(18,2) | Tax at applicable slab rates |
| `surcharge` | NUMERIC(18,2) | Surcharge on tax |
| `cess` | NUMERIC(18,2) | 4% Health & Education cess |
| `total_tax_liability` | NUMERIC(18,2) | basic_tax + surcharge + cess |
| `tds_credit` | NUMERIC(18,2) | Total TDS credit claimed |
| `advance_tax_credit` | NUMERIC(18,2) | Advance tax payments |
| `self_assessment_tax` | NUMERIC(18,2) | Self-assessment tax paid |
| `net_payable` | NUMERIC(18,2) | Additional tax to be paid |
| `net_refund` | NUMERIC(18,2) | Refund due |
| `regime` | VARCHAR(10) | old / new (tax regime) |
| `computed_at` | TIMESTAMPTZ | Computation timestamp |

---

### ndfl.tax_payments

**Purpose:** Advance tax challan and self-assessment tax payment records.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Payment record identifier |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Taxpayer |
| `payment_type` | VARCHAR(30) NOT NULL | advance_tax / self_assessment / regular_assessment |
| `challan_number` | VARCHAR(50) | Challan identification number |
| `bsr_code` | VARCHAR(7) | BSR code of receiving bank branch |
| `payment_date` | DATE NOT NULL | Date of tax payment |
| `amount` | NUMERIC(18,2) NOT NULL | Amount paid |
| `bank_name` | VARCHAR(100) | Bank through which payment made |
| `minor_head_code` | VARCHAR(10) | Minor head code (300, 400, etc.) |
| `metadata` | JSONB | Additional payment details |

---

### ndfl.tax_documents

**Purpose:** Document upload metadata for supporting tax documents.

| Column | Type | Description |
|---|---|---|
| `id` | UUID PK | Document record identifier |
| `tax_year_id` | UUID FK → tax_years | Parent tax year |
| `user_id` | UUID FK → shared.users | Document owner |
| `document_type` | VARCHAR(50) NOT NULL | form16 / form16a / form26as / computation / itr_ack / capital_gains_statement / other |
| `file_name` | VARCHAR(255) NOT NULL | Original file name |
| `file_url` | TEXT NOT NULL | Storage URL (S3 / GCS) |
| `mime_type` | VARCHAR(100) | MIME type of the uploaded file |
| `file_size_bytes` | BIGINT | File size in bytes |
| `uploaded_at` | TIMESTAMPTZ NOT NULL | Upload timestamp |
| `verified` | BOOLEAN | Whether document has been verified |
| `metadata` | JSONB | Document-specific attributes |
