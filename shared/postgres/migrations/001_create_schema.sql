-- ============================================================
-- Migration: 001_create_schema
-- Domain: shared (users, auth, billing, notifications)
-- Run this first before any project-specific schemas
-- ============================================================

CREATE SCHEMA IF NOT EXISTS shared;

-- Extensions (required by all schemas)
\i shared/postgres/ddl/000_extensions.sql

-- Enums
\i shared/postgres/ddl/000_enums.sql

-- Core auth tables
\i shared/postgres/ddl/001_users.sql
\i shared/postgres/ddl/002_roles.sql
\i shared/postgres/ddl/003_permissions.sql
\i shared/postgres/ddl/004_user_roles.sql

-- Session & API access
\i shared/postgres/ddl/005_sessions.sql
\i shared/postgres/ddl/006_api_keys.sql

-- Billing
\i shared/postgres/ddl/007_subscriptions.sql
\i shared/postgres/ddl/008_billing_transactions.sql

-- Audit & activity
\i shared/postgres/ddl/009_audit_logs.sql
\i shared/postgres/ddl/010_user_preferences.sql
\i shared/postgres/ddl/011_devices.sql
\i shared/postgres/ddl/012_oauth_accounts.sql
\i shared/postgres/ddl/013_notifications.sql

-- Indexes
\i shared/postgres/indexes/idx_users.sql
\i shared/postgres/indexes/idx_sessions.sql
\i shared/postgres/indexes/idx_api_keys.sql
\i shared/postgres/indexes/idx_audit_logs.sql

-- Functions
\i shared/postgres/functions/audit_trigger_function.sql
\i shared/postgres/functions/soft_delete_function.sql

-- Triggers
\i shared/postgres/triggers/users_trigger.sql

-- Seed data
\i shared/postgres/dml/seed_001_users.sql
