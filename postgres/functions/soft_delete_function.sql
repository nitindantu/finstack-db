-- ============================================================
-- Function: soft_delete(table_name TEXT, record_id UUID)
-- Marks a record as deleted by setting deleted_at = NOW()
-- ============================================================

CREATE OR REPLACE FUNCTION soft_delete(p_table_name TEXT, p_record_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_query TEXT;
    v_rows_affected INTEGER;
    v_allowed_tables TEXT[] := ARRAY[
        'users','roles','api_keys','portfolios','portfolio_positions',
        'portfolio_transactions','watchlists','screener_templates',
        'saved_screeners','strategies','backtests','alerts',
        'broker_accounts','orders','companies','goals','notifications',
        'custom_formulas','ml_models','ai_recommendations'
    ];
BEGIN
    -- Whitelist check to prevent SQL injection via table name
    IF NOT (p_table_name = ANY(v_allowed_tables)) THEN
        RAISE EXCEPTION 'Table % is not permitted for soft_delete', p_table_name
            USING ERRCODE = 'P0002';
    END IF;

    v_query := format(
        'UPDATE %I SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL',
        p_table_name
    );

    EXECUTE v_query USING p_record_id;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    RETURN v_rows_affected > 0;
END;
$$;

COMMENT ON FUNCTION soft_delete(TEXT, UUID) IS 'Sets deleted_at to NOW() on the specified record; table name must be in the whitelist';


-- ============================================================
-- Function: restore_soft_deleted(table_name TEXT, record_id UUID)
-- Restores a soft-deleted record
-- ============================================================

CREATE OR REPLACE FUNCTION restore_soft_deleted(p_table_name TEXT, p_record_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_query TEXT;
    v_rows_affected INTEGER;
    v_allowed_tables TEXT[] := ARRAY[
        'users','roles','api_keys','portfolios','portfolio_positions',
        'portfolio_transactions','watchlists','screener_templates',
        'saved_screeners','strategies','backtests','alerts',
        'broker_accounts','orders','companies','goals'
    ];
BEGIN
    IF NOT (p_table_name = ANY(v_allowed_tables)) THEN
        RAISE EXCEPTION 'Table % is not permitted for restore_soft_deleted', p_table_name
            USING ERRCODE = 'P0002';
    END IF;

    v_query := format(
        'UPDATE %I SET deleted_at = NULL, updated_at = NOW() WHERE id = $1 AND deleted_at IS NOT NULL',
        p_table_name
    );

    EXECUTE v_query USING p_record_id;
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    RETURN v_rows_affected > 0;
END;
$$;

COMMENT ON FUNCTION restore_soft_deleted(TEXT, UUID) IS 'Clears deleted_at on a soft-deleted record; useful for admin restores';
