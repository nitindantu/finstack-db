-- ============================================================
-- ScreenerX Shared Enum Types
-- Run after extensions, before all table DDL
-- ============================================================

-- USER & AUTH DOMAIN
DO $$ BEGIN
  CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended', 'deleted');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE plan_type AS ENUM ('free', 'basic', 'premium', 'enterprise');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE subscription_status AS ENUM ('trialing', 'active', 'past_due', 'cancelled', 'unpaid', 'incomplete', 'incomplete_expired', 'paused');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE billing_status AS ENUM ('pending', 'succeeded', 'failed', 'refunded', 'disputed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE device_platform AS ENUM ('ios', 'android', 'web');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE oauth_provider AS ENUM ('google', 'github', 'facebook', 'twitter', 'linkedin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE notification_channel AS ENUM ('push', 'email', 'sms', 'in_app');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE notification_type AS ENUM ('alert', 'system', 'marketing', 'report', 'trade', 'news');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE sentiment_label AS ENUM ('very_bearish', 'bearish', 'neutral', 'bullish', 'very_bullish');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- MARKET DATA DOMAIN
DO $$ BEGIN
  CREATE TYPE instrument_type AS ENUM ('equity', 'etf', 'index', 'futures', 'options', 'mutual_fund', 'bond', 'currency', 'commodity');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_book_side AS ENUM ('bid', 'ask');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE corporate_action_type AS ENUM ('dividend', 'split', 'bonus', 'rights', 'merger', 'delisting', 'buyback', 'amalgamation', 'demerger');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE dividend_type AS ENUM ('interim', 'final', 'special');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE period_type AS ENUM ('Q1', 'Q2', 'Q3', 'Q4', 'Annual', 'TTM');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE event_importance AS ENUM ('low', 'medium', 'high');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE sentiment_source AS ENUM ('news', 'twitter', 'reddit', 'analyst', 'options_flow', 'insider');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- SCREENER DOMAIN
DO $$ BEGIN
  CREATE TYPE filter_operator AS ENUM ('gt', 'lt', 'gte', 'lte', 'eq', 'neq', 'in', 'not_in', 'between', 'contains', 'starts_with', 'ends_with', 'is_null', 'is_not_null');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- PORTFOLIO DOMAIN
DO $$ BEGIN
  CREATE TYPE portfolio_type AS ENUM ('real', 'paper', 'model');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE transaction_type AS ENUM ('buy', 'sell', 'dividend', 'split', 'bonus', 'transfer_in', 'transfer_out', 'interest', 'fee');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE goal_type AS ENUM ('retirement', 'education', 'house', 'emergency', 'travel', 'custom');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE goal_status AS ENUM ('active', 'completed', 'paused', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE rebalancing_rule_type AS ENUM ('target_weight', 'threshold', 'calendar');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- TRADING DOMAIN
DO $$ BEGIN
  CREATE TYPE account_type AS ENUM ('demat', 'trading', 'commodity', 'currency', 'mutual_fund');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_type AS ENUM ('market', 'limit', 'stop', 'stop_limit', 'bracket', 'cover', 'trailing_stop');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_side AS ENUM ('buy', 'sell');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_type AS ENUM ('intraday', 'delivery', 'futures', 'options', 'currency', 'commodity');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_status AS ENUM ('pending', 'open', 'partial', 'filled', 'cancelled', 'rejected', 'expired', 'amo_pending');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE order_validity AS ENUM ('day', 'ioc', 'gtc', 'gtd', 'amo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE risk_limit_type AS ENUM ('max_position_size', 'max_daily_loss', 'max_drawdown', 'sector_concentration', 'var', 'max_leverage');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE breach_action AS ENUM ('alert', 'block', 'liquidate');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- STRATEGY & BACKTEST DOMAIN
DO $$ BEGIN
  CREATE TYPE strategy_type AS ENUM ('momentum', 'mean_reversion', 'arbitrage', 'ml', 'manual', 'factor', 'pairs_trading', 'statistical_arb');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE backtest_status AS ENUM ('queued', 'running', 'completed', 'failed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE signal_type AS ENUM ('long', 'short', 'exit', 'scale_in', 'scale_out');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- AI/ML DOMAIN
DO $$ BEGIN
  CREATE TYPE ml_model_type AS ENUM ('classification', 'regression', 'clustering', 'nlp', 'rl', 'time_series', 'anomaly_detection');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE run_status AS ENUM ('pending', 'running', 'completed', 'failed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE recommendation_type AS ENUM ('buy', 'sell', 'hold', 'watch', 'avoid');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE drift_type AS ENUM ('data', 'concept', 'model', 'covariate');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ALERTS DOMAIN
DO $$ BEGIN
  CREATE TYPE alert_type AS ENUM ('price', 'volume', 'technical', 'fundamental', 'news', 'custom', 'earnings', 'insider');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- INSTITUTION TYPE
DO $$ BEGIN
  CREATE TYPE institution_type AS ENUM ('fii', 'dii', 'insurance', 'bank', 'mf', 'hedge_fund', 'pension_fund');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ANALYST RATING
DO $$ BEGIN
  CREATE TYPE analyst_rating AS ENUM ('strong_buy', 'buy', 'hold', 'sell', 'strong_sell', 'not_rated');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
