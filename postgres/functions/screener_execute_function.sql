-- ============================================================
-- Function: execute_screener(p_filters JSONB, p_sort_by TEXT,
--           p_sort_order TEXT, p_limit INT, p_offset INT)
-- Dynamic screener query builder that returns matching symbols
-- ============================================================

CREATE OR REPLACE FUNCTION execute_screener(
    p_filters       JSONB       DEFAULT '[]',
    p_sort_by       TEXT        DEFAULT 'financial_ratios.pe_ratio',
    p_sort_order    TEXT        DEFAULT 'asc',
    p_limit         INTEGER     DEFAULT 100,
    p_offset        INTEGER     DEFAULT 0
)
RETURNS TABLE (
    symbol_id               UUID,
    ticker                  TEXT,
    company_name            TEXT,
    exchange_code           TEXT,
    sector                  TEXT,
    industry                TEXT,
    market_cap_category     TEXT,
    pe_ratio                NUMERIC,
    pb_ratio                NUMERIC,
    ps_ratio                NUMERIC,
    roe                     NUMERIC,
    roa                     NUMERIC,
    debt_to_equity          NUMERIC,
    dividend_yield          NUMERIC,
    revenue_growth_yoy      NUMERIC,
    earnings_growth_yoy     NUMERIC,
    current_ratio           NUMERIC,
    ev_ebitda               NUMERIC,
    as_of_date              DATE
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_where_clauses     TEXT[] := ARRAY[]::TEXT[];
    v_filter            JSONB;
    v_field             TEXT;
    v_op                TEXT;
    v_value             NUMERIC;
    v_value_text        TEXT;
    v_value_min         NUMERIC;
    v_value_max         NUMERIC;
    v_final_where       TEXT;
    v_sort_col          TEXT;
    v_sql               TEXT;
    v_allowed_sort_cols TEXT[] := ARRAY[
        'fr.pe_ratio','fr.pb_ratio','fr.ps_ratio','fr.roe','fr.roa',
        'fr.debt_to_equity','fr.dividend_yield','fr.revenue_growth_yoy',
        'fr.earnings_growth_yoy','fr.current_ratio','fr.ev_ebitda',
        's.ticker','c.registered_name'
    ];
BEGIN
    -- Validate sort order
    IF lower(p_sort_order) NOT IN ('asc','desc') THEN
        p_sort_order := 'asc';
    END IF;

    -- Validate and map sort column
    v_sort_col := CASE p_sort_by
        WHEN 'financial_ratios.pe_ratio'            THEN 'fr.pe_ratio'
        WHEN 'financial_ratios.pb_ratio'            THEN 'fr.pb_ratio'
        WHEN 'financial_ratios.roe'                 THEN 'fr.roe'
        WHEN 'financial_ratios.dividend_yield'      THEN 'fr.dividend_yield'
        WHEN 'financial_ratios.revenue_growth_yoy'  THEN 'fr.revenue_growth_yoy'
        WHEN 'financial_ratios.earnings_growth_yoy' THEN 'fr.earnings_growth_yoy'
        WHEN 'ticker'                               THEN 's.ticker'
        ELSE 'fr.pe_ratio'
    END;

    -- Build WHERE clauses from filter array
    FOR v_filter IN SELECT * FROM jsonb_array_elements(p_filters) LOOP
        v_field     := v_filter->>'field';
        v_op        := v_filter->>'op';

        -- Map field path to aliased SQL column
        v_field := CASE v_field
            WHEN 'financial_ratios.pe_ratio'            THEN 'fr.pe_ratio'
            WHEN 'financial_ratios.pb_ratio'            THEN 'fr.pb_ratio'
            WHEN 'financial_ratios.ps_ratio'            THEN 'fr.ps_ratio'
            WHEN 'financial_ratios.roe'                 THEN 'fr.roe'
            WHEN 'financial_ratios.roa'                 THEN 'fr.roa'
            WHEN 'financial_ratios.debt_to_equity'      THEN 'fr.debt_to_equity'
            WHEN 'financial_ratios.dividend_yield'      THEN 'fr.dividend_yield'
            WHEN 'financial_ratios.revenue_growth_yoy'  THEN 'fr.revenue_growth_yoy'
            WHEN 'financial_ratios.earnings_growth_yoy' THEN 'fr.earnings_growth_yoy'
            WHEN 'financial_ratios.current_ratio'       THEN 'fr.current_ratio'
            WHEN 'financial_ratios.ev_ebitda'           THEN 'fr.ev_ebitda'
            WHEN 'symbols.sector'                       THEN 's.sector'
            WHEN 'symbols.market_cap_category'          THEN 's.market_cap_category'
            WHEN 'symbols.instrument_type'              THEN 's.instrument_type'
            ELSE NULL
        END;

        -- Skip unknown fields
        IF v_field IS NULL THEN
            CONTINUE;
        END IF;

        -- Build clause for each operator
        CASE v_op
            WHEN 'gt'  THEN
                v_value := (v_filter->>'value')::NUMERIC;
                v_where_clauses := v_where_clauses || format('%s > %s', v_field, v_value);
            WHEN 'gte' THEN
                v_value := (v_filter->>'value')::NUMERIC;
                v_where_clauses := v_where_clauses || format('%s >= %s', v_field, v_value);
            WHEN 'lt'  THEN
                v_value := (v_filter->>'value')::NUMERIC;
                v_where_clauses := v_where_clauses || format('%s < %s', v_field, v_value);
            WHEN 'lte' THEN
                v_value := (v_filter->>'value')::NUMERIC;
                v_where_clauses := v_where_clauses || format('%s <= %s', v_field, v_value);
            WHEN 'eq'  THEN
                v_value_text := v_filter->>'value';
                v_where_clauses := v_where_clauses || format('%s = %L', v_field, v_value_text);
            WHEN 'between' THEN
                v_value_min := (v_filter->>'min')::NUMERIC;
                v_value_max := (v_filter->>'max')::NUMERIC;
                v_where_clauses := v_where_clauses || format('%s BETWEEN %s AND %s', v_field, v_value_min, v_value_max);
            ELSE
                -- Skip unsupported operators
                CONTINUE;
        END CASE;
    END LOOP;

    -- Compose final WHERE clause
    IF array_length(v_where_clauses, 1) > 0 THEN
        v_final_where := 'AND ' || array_to_string(v_where_clauses, ' AND ');
    ELSE
        v_final_where := '';
    END IF;

    -- Build and execute the dynamic SQL
    v_sql := format(
        'SELECT
            s.id                    AS symbol_id,
            s.ticker                AS ticker,
            c.registered_name       AS company_name,
            e.code                  AS exchange_code,
            s.sector,
            s.industry,
            s.market_cap_category,
            fr.pe_ratio,
            fr.pb_ratio,
            fr.ps_ratio,
            fr.roe,
            fr.roa,
            fr.debt_to_equity,
            fr.dividend_yield,
            fr.revenue_growth_yoy,
            fr.earnings_growth_yoy,
            fr.current_ratio,
            fr.ev_ebitda,
            fr.as_of_date
        FROM symbols s
        JOIN exchanges e ON s.exchange_id = e.id
        LEFT JOIN companies c ON c.symbol_id = s.id AND c.deleted_at IS NULL
        LEFT JOIN LATERAL (
            SELECT * FROM financial_ratios fr2
            WHERE fr2.symbol_id = s.id
            ORDER BY fr2.as_of_date DESC
            LIMIT 1
        ) fr ON TRUE
        WHERE s.is_active = TRUE
          AND s.instrument_type = ''equity''
          %s
        ORDER BY %s %s NULLS LAST
        LIMIT %s OFFSET %s',
        v_final_where,
        v_sort_col,
        upper(p_sort_order),
        p_limit,
        p_offset
    );

    RETURN QUERY EXECUTE v_sql;
END;
$$;

COMMENT ON FUNCTION execute_screener(JSONB, TEXT, TEXT, INTEGER, INTEGER)
IS 'Dynamic screener: accepts a JSON filter array and returns matching symbols with latest financial ratios';
