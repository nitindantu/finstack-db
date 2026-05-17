-- ============================================================
-- Row Level Security Policies
-- Tenant and user isolation for multi-tenant data
-- ============================================================

-- Helper function: get current user's UUID from JWT claim
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
$$;

-- Helper function: get current tenant's UUID from JWT claim
CREATE OR REPLACE FUNCTION current_tenant_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT NULLIF(current_setting('app.current_tenant_id', TRUE), '')::UUID;
$$;

-- Helper function: check if current user is an admin
CREATE OR REPLACE FUNCTION current_user_is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT COALESCE(current_setting('app.is_admin', TRUE)::BOOLEAN, FALSE);
$$;

-- ============================================================
-- RLS on users
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_tenant_isolation ON users;
CREATE POLICY users_tenant_isolation ON users
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        tenant_id = current_tenant_id()
        OR current_user_is_admin()
    )
    WITH CHECK (
        tenant_id = current_tenant_id()
        OR current_user_is_admin()
    );

-- Users can only update their own record (admins can update any)
DROP POLICY IF EXISTS users_self_update ON users;
CREATE POLICY users_self_update ON users
    AS PERMISSIVE
    FOR UPDATE
    TO PUBLIC
    USING (
        id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on portfolios
-- ============================================================
ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolios FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS portfolios_owner_policy ON portfolios;
CREATE POLICY portfolios_owner_policy ON portfolios
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        (user_id = current_user_id() AND tenant_id = current_tenant_id())
        OR current_user_is_admin()
    )
    WITH CHECK (
        (user_id = current_user_id() AND tenant_id = current_tenant_id())
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on portfolio_positions
-- ============================================================
ALTER TABLE portfolio_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_positions FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS portfolio_positions_owner ON portfolio_positions;
CREATE POLICY portfolio_positions_owner ON portfolio_positions
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        EXISTS (
            SELECT 1 FROM portfolios pf
            WHERE pf.id = portfolio_positions.portfolio_id
              AND (pf.user_id = current_user_id() OR current_user_is_admin())
        )
    );

-- ============================================================
-- RLS on portfolio_transactions
-- ============================================================
ALTER TABLE portfolio_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_transactions FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS portfolio_transactions_owner ON portfolio_transactions;
CREATE POLICY portfolio_transactions_owner ON portfolio_transactions
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        EXISTS (
            SELECT 1 FROM portfolios pf
            WHERE pf.id = portfolio_transactions.portfolio_id
              AND (pf.user_id = current_user_id() OR current_user_is_admin())
        )
    );

-- ============================================================
-- RLS on orders
-- ============================================================
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS orders_owner ON orders;
CREATE POLICY orders_owner ON orders
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    )
    WITH CHECK (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on watchlists
-- ============================================================
ALTER TABLE watchlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlists FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS watchlists_owner_or_public ON watchlists;
CREATE POLICY watchlists_owner_or_public ON watchlists
    AS PERMISSIVE
    FOR SELECT
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR is_public = TRUE
        OR current_user_is_admin()
    );

DROP POLICY IF EXISTS watchlists_owner_write ON watchlists;
CREATE POLICY watchlists_owner_write ON watchlists
    AS PERMISSIVE
    FOR INSERT
    TO PUBLIC
    WITH CHECK (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

DROP POLICY IF EXISTS watchlists_owner_update ON watchlists;
CREATE POLICY watchlists_owner_update ON watchlists
    AS PERMISSIVE
    FOR UPDATE
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on alerts
-- ============================================================
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS alerts_owner ON alerts;
CREATE POLICY alerts_owner ON alerts
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    )
    WITH CHECK (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on screener_templates
-- ============================================================
ALTER TABLE screener_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE screener_templates FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS screener_templates_access ON screener_templates;
CREATE POLICY screener_templates_access ON screener_templates
    AS PERMISSIVE
    FOR SELECT
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR is_public = TRUE
        OR is_system = TRUE
        OR (tenant_id = current_tenant_id() AND is_public = TRUE)
        OR current_user_is_admin()
    );

DROP POLICY IF EXISTS screener_templates_write ON screener_templates;
CREATE POLICY screener_templates_write ON screener_templates
    AS PERMISSIVE
    FOR INSERT
    TO PUBLIC
    WITH CHECK (
        user_id = current_user_id()
        AND tenant_id = current_tenant_id()
    );

DROP POLICY IF EXISTS screener_templates_update ON screener_templates;
CREATE POLICY screener_templates_update ON screener_templates
    AS PERMISSIVE
    FOR UPDATE
    TO PUBLIC
    USING (
        (user_id = current_user_id() AND NOT is_system)
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on strategies
-- ============================================================
ALTER TABLE strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE strategies FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS strategies_access ON strategies;
CREATE POLICY strategies_access ON strategies
    AS PERMISSIVE
    FOR SELECT
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR is_public = TRUE
        OR current_user_is_admin()
    );

DROP POLICY IF EXISTS strategies_write ON strategies;
CREATE POLICY strategies_write ON strategies
    AS PERMISSIVE
    FOR INSERT
    TO PUBLIC
    WITH CHECK (
        user_id = current_user_id()
    );

DROP POLICY IF EXISTS strategies_update ON strategies;
CREATE POLICY strategies_update ON strategies
    AS PERMISSIVE
    FOR UPDATE
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on notifications
-- ============================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notifications_owner ON notifications;
CREATE POLICY notifications_owner ON notifications
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    );

-- ============================================================
-- RLS on api_keys
-- ============================================================
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS api_keys_owner ON api_keys;
CREATE POLICY api_keys_owner ON api_keys
    AS PERMISSIVE
    FOR ALL
    TO PUBLIC
    USING (
        user_id = current_user_id()
        OR current_user_is_admin()
    )
    WITH CHECK (
        user_id = current_user_id()
        OR current_user_is_admin()
    );
