-- ============================================================
-- Function: calculate_portfolio_nav(p_portfolio_id UUID)
-- Returns the current Net Asset Value of a portfolio
-- based on live positions and their last known prices
-- ============================================================

CREATE OR REPLACE FUNCTION calculate_portfolio_nav(p_portfolio_id UUID)
RETURNS TABLE (
    portfolio_id        UUID,
    total_value         NUMERIC,
    invested_value      NUMERIC,
    unrealized_pnl      NUMERIC,
    unrealized_pnl_pct  NUMERIC,
    realized_pnl        NUMERIC,
    position_count      INTEGER,
    as_of               TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pp.portfolio_id,
        SUM(pp.quantity * COALESCE(pp.current_price, pp.avg_cost))::NUMERIC        AS total_value,
        SUM(pp.quantity * pp.avg_cost)::NUMERIC                                    AS invested_value,
        SUM(pp.quantity * COALESCE(pp.current_price, pp.avg_cost) - pp.quantity * pp.avg_cost)::NUMERIC AS unrealized_pnl,
        CASE
            WHEN SUM(pp.quantity * pp.avg_cost) > 0
            THEN ((SUM(pp.quantity * COALESCE(pp.current_price, pp.avg_cost)) / SUM(pp.quantity * pp.avg_cost)) - 1)::NUMERIC
            ELSE 0::NUMERIC
        END                                                                        AS unrealized_pnl_pct,
        SUM(pp.realized_pnl)::NUMERIC                                              AS realized_pnl,
        COUNT(pp.id)::INTEGER                                                      AS position_count,
        NOW()                                                                      AS as_of
    FROM portfolio_positions pp
    WHERE pp.portfolio_id = p_portfolio_id
      AND pp.deleted_at IS NULL
      AND pp.quantity > 0
    GROUP BY pp.portfolio_id;
END;
$$;

COMMENT ON FUNCTION calculate_portfolio_nav(UUID) IS 'Calculates the current NAV of a portfolio from its open positions';


-- ============================================================
-- Function: take_portfolio_snapshot(p_portfolio_id UUID)
-- Takes and stores an end-of-day snapshot
-- ============================================================

CREATE OR REPLACE FUNCTION take_portfolio_snapshot(p_portfolio_id UUID)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_nav_row       RECORD;
    v_prev_total    NUMERIC;
BEGIN
    SELECT * INTO v_nav_row FROM calculate_portfolio_nav(p_portfolio_id);

    -- Get previous snapshot for day_pnl calculation
    SELECT total_value INTO v_prev_total
    FROM portfolio_snapshots
    WHERE portfolio_id = p_portfolio_id
    ORDER BY snapshot_date DESC
    LIMIT 1;

    INSERT INTO portfolio_snapshots (
        portfolio_id, snapshot_date, total_value,
        invested_value, unrealized_pnl, realized_pnl,
        day_pnl, positions_snapshot
    )
    VALUES (
        p_portfolio_id,
        CURRENT_DATE,
        COALESCE(v_nav_row.total_value, 0),
        COALESCE(v_nav_row.invested_value, 0),
        COALESCE(v_nav_row.unrealized_pnl, 0),
        COALESCE(v_nav_row.realized_pnl, 0),
        COALESCE(v_nav_row.total_value, 0) - COALESCE(v_prev_total, COALESCE(v_nav_row.total_value, 0)),
        (
            SELECT jsonb_agg(jsonb_build_object(
                'symbol_id',  pp.symbol_id,
                'quantity',   pp.quantity,
                'avg_cost',   pp.avg_cost,
                'current_price', pp.current_price,
                'current_value', pp.current_value,
                'unrealized_pnl', pp.unrealized_pnl
            ))
            FROM portfolio_positions pp
            WHERE pp.portfolio_id = p_portfolio_id AND pp.deleted_at IS NULL AND pp.quantity > 0
        )
    )
    ON CONFLICT (portfolio_id, snapshot_date)
    DO UPDATE SET
        total_value         = EXCLUDED.total_value,
        invested_value      = EXCLUDED.invested_value,
        unrealized_pnl      = EXCLUDED.unrealized_pnl,
        realized_pnl        = EXCLUDED.realized_pnl,
        day_pnl             = EXCLUDED.day_pnl,
        positions_snapshot  = EXCLUDED.positions_snapshot;
END;
$$;

COMMENT ON FUNCTION take_portfolio_snapshot(UUID) IS 'Captures an end-of-day portfolio snapshot; upserts by date to be idempotent';


-- ============================================================
-- Function: update_position_on_transaction()
-- Trigger function: recalculates portfolio_positions on new transaction
-- ============================================================

CREATE OR REPLACE FUNCTION update_position_on_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_qty      NUMERIC;
    v_existing_avg_cost NUMERIC;
    v_new_qty           NUMERIC;
    v_new_avg_cost      NUMERIC;
BEGIN
    IF NEW.transaction_type = 'buy' THEN
        -- Check for existing position
        SELECT quantity, avg_cost
        INTO v_existing_qty, v_existing_avg_cost
        FROM portfolio_positions
        WHERE portfolio_id = NEW.portfolio_id AND symbol_id = NEW.symbol_id AND deleted_at IS NULL;

        IF FOUND THEN
            -- Weighted average cost
            v_new_qty      := v_existing_qty + NEW.quantity;
            v_new_avg_cost := (v_existing_qty * v_existing_avg_cost + NEW.quantity * NEW.price) / v_new_qty;

            UPDATE portfolio_positions
            SET quantity                = v_new_qty,
                avg_cost                = v_new_avg_cost,
                last_transaction_date   = NEW.transaction_date,
                updated_at              = NOW()
            WHERE portfolio_id = NEW.portfolio_id AND symbol_id = NEW.symbol_id;
        ELSE
            INSERT INTO portfolio_positions (portfolio_id, symbol_id, quantity, avg_cost, first_buy_date, last_transaction_date)
            VALUES (NEW.portfolio_id, NEW.symbol_id, NEW.quantity, NEW.price, NEW.transaction_date, NEW.transaction_date);
        END IF;

    ELSIF NEW.transaction_type = 'sell' THEN
        SELECT quantity, avg_cost
        INTO v_existing_qty, v_existing_avg_cost
        FROM portfolio_positions
        WHERE portfolio_id = NEW.portfolio_id AND symbol_id = NEW.symbol_id AND deleted_at IS NULL;

        IF FOUND THEN
            v_new_qty := v_existing_qty - NEW.quantity;

            IF v_new_qty < 0 THEN
                RAISE EXCEPTION 'Insufficient quantity for sell: have %, selling %', v_existing_qty, NEW.quantity;
            END IF;

            IF v_new_qty = 0 THEN
                -- Close out position
                UPDATE portfolio_positions
                SET quantity                = 0,
                    realized_pnl            = realized_pnl + (NEW.price - v_existing_avg_cost) * NEW.quantity,
                    last_transaction_date   = NEW.transaction_date,
                    updated_at              = NOW()
                WHERE portfolio_id = NEW.portfolio_id AND symbol_id = NEW.symbol_id;
            ELSE
                UPDATE portfolio_positions
                SET quantity                = v_new_qty,
                    realized_pnl            = realized_pnl + (NEW.price - v_existing_avg_cost) * NEW.quantity,
                    last_transaction_date   = NEW.transaction_date,
                    updated_at              = NOW()
                WHERE portfolio_id = NEW.portfolio_id AND symbol_id = NEW.symbol_id;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION update_position_on_transaction() IS 'Trigger: keeps portfolio_positions in sync when a new transaction is inserted';
