-- ============================================================
-- Triggers: portfolio_transactions / portfolio_positions
-- ============================================================

-- Auto-update updated_at on portfolios
DROP TRIGGER IF EXISTS trg_portfolios_updated_at ON portfolios;
CREATE TRIGGER trg_portfolios_updated_at
    BEFORE UPDATE ON portfolios
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Auto-update updated_at on portfolio_positions
DROP TRIGGER IF EXISTS trg_portfolio_positions_updated_at ON portfolio_positions;
CREATE TRIGGER trg_portfolio_positions_updated_at
    BEFORE UPDATE ON portfolio_positions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- On new transaction, update portfolio_positions
DROP TRIGGER IF EXISTS trg_portfolio_transaction_update_position ON portfolio_transactions;
CREATE TRIGGER trg_portfolio_transaction_update_position
    AFTER INSERT ON portfolio_transactions
    FOR EACH ROW
    WHEN (NEW.transaction_type IN ('buy', 'sell'))
    EXECUTE FUNCTION update_position_on_transaction();

-- Maintain watchlist item_count
CREATE OR REPLACE FUNCTION update_watchlist_item_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE watchlists SET item_count = item_count + 1, updated_at = NOW()
        WHERE id = NEW.watchlist_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE watchlists SET item_count = GREATEST(item_count - 1, 0), updated_at = NOW()
        WHERE id = OLD.watchlist_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_watchlist_items_count ON watchlist_items;
CREATE TRIGGER trg_watchlist_items_count
    AFTER INSERT OR DELETE ON watchlist_items
    FOR EACH ROW EXECUTE FUNCTION update_watchlist_item_count();
