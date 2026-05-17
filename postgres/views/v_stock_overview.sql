-- ============================================================
-- View: v_stock_overview
-- Joins symbols + exchanges + companies + latest financial_ratios
-- + latest daily price for a complete one-stop stock card
-- ============================================================

CREATE OR REPLACE VIEW v_stock_overview AS
SELECT
    s.id                            AS symbol_id,
    s.ticker,
    s.name                          AS symbol_name,
    s.isin,
    s.sector,
    s.industry,
    s.market_cap_category,
    s.instrument_type,
    s.listing_date,
    e.id                            AS exchange_id,
    e.code                          AS exchange_code,
    e.name                          AS exchange_name,
    e.currency                      AS trading_currency,
    c.id                            AS company_id,
    c.registered_name               AS company_name,
    c.about                         AS company_about,
    c.website,
    c.founded_year,
    c.employee_count,
    c.headquarters,
    c.promoter_names,
    -- Latest daily price
    dp.open                         AS day_open,
    dp.high                         AS day_high,
    dp.low                          AS day_low,
    dp.close                        AS last_price,
    dp.volume                       AS day_volume,
    dp.vwap                         AS day_vwap,
    dp.delivery_pct,
    dp.date                         AS price_date,
    -- Latest financial ratios
    fr.pe_ratio,
    fr.pb_ratio,
    fr.ps_ratio,
    fr.ev_ebitda,
    fr.roe,
    fr.roa,
    fr.roce,
    fr.roic,
    fr.debt_to_equity,
    fr.current_ratio,
    fr.quick_ratio,
    fr.dividend_yield,
    fr.payout_ratio,
    fr.revenue_growth_yoy,
    fr.earnings_growth_yoy,
    fr.as_of_date                   AS ratios_as_of
FROM symbols s
JOIN exchanges e ON s.exchange_id = e.id
LEFT JOIN companies c ON c.symbol_id = s.id AND c.deleted_at IS NULL
LEFT JOIN LATERAL (
    SELECT * FROM market_data_1d d
    WHERE d.symbol_id = s.id
    ORDER BY d.date DESC
    LIMIT 1
) dp ON TRUE
LEFT JOIN LATERAL (
    SELECT * FROM financial_ratios r
    WHERE r.symbol_id = s.id
    ORDER BY r.as_of_date DESC
    LIMIT 1
) fr ON TRUE
WHERE s.is_active = TRUE;

COMMENT ON VIEW v_stock_overview IS 'Combined stock card: symbol + exchange + company + latest price + latest ratios';
