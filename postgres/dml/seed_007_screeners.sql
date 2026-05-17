-- ============================================================
-- Seed Data: screener_templates, screener_filters,
--            saved_screeners, roles, permissions
-- ============================================================

-- roles
INSERT INTO roles (id, tenant_id, name, description, is_system, permissions)
VALUES
  ('r0000001-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001', 'admin',          'Full platform administrator',              TRUE, '["*"]'),
  ('r0000001-0000-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000001', 'analyst',         'Read all data, run screeners and backtests', TRUE, '["portfolio.read","screener.execute","backtest.create","market_data.read"]'),
  ('r0000001-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000001', 'trader',          'Can place and manage orders',              TRUE, '["order.create","order.cancel","portfolio.manage","screener.execute"]'),
  ('r0000001-0000-4000-8000-000000000004', 'f0000000-0000-4000-8000-000000000001', 'viewer',          'Read-only access to market data',          TRUE, '["market_data.read","screener.read","portfolio.read"]'),
  ('r0000001-0000-4000-8000-000000000005', 'f0000000-0000-4000-8000-000000000002', 'fund_manager',    'Manage model portfolios and strategies',   FALSE, '["portfolio.manage","strategy.create","backtest.create","screener.execute"]')
ON CONFLICT DO NOTHING;

-- permissions
INSERT INTO permissions (id, code, name, description, resource, action)
VALUES
  ('pm000001-0000-4000-8000-000000000001', 'portfolio.create', 'Create Portfolio',    'Create a new portfolio',                       'portfolio', 'create'),
  ('pm000001-0000-4000-8000-000000000002', 'portfolio.read',   'Read Portfolio',      'View portfolio details and positions',          'portfolio', 'read'),
  ('pm000001-0000-4000-8000-000000000003', 'portfolio.update', 'Update Portfolio',    'Modify portfolio settings',                     'portfolio', 'update'),
  ('pm000001-0000-4000-8000-000000000004', 'portfolio.delete', 'Delete Portfolio',    'Delete a portfolio',                            'portfolio', 'delete'),
  ('pm000001-0000-4000-8000-000000000005', 'portfolio.manage', 'Manage Portfolio',    'Full CRUD on portfolios and transactions',      'portfolio', 'manage'),
  ('pm000001-0000-4000-8000-000000000006', 'order.create',     'Place Order',         'Place buy/sell orders',                         'order',     'create'),
  ('pm000001-0000-4000-8000-000000000007', 'order.cancel',     'Cancel Order',        'Cancel open orders',                            'order',     'delete'),
  ('pm000001-0000-4000-8000-000000000008', 'screener.execute', 'Run Screener',        'Execute stock screener queries',                'screener',  'execute'),
  ('pm000001-0000-4000-8000-000000000009', 'screener.read',    'View Screener',       'View screener results',                         'screener',  'read'),
  ('pm000001-0000-4000-8000-000000000010', 'screener.create',  'Create Screener',     'Create and save screener templates',            'screener',  'create'),
  ('pm000001-0000-4000-8000-000000000011', 'market_data.read', 'Read Market Data',    'Access live and historical market data',        'market_data','read'),
  ('pm000001-0000-4000-8000-000000000012', 'strategy.create',  'Create Strategy',     'Create trading strategies',                     'strategy',  'create'),
  ('pm000001-0000-4000-8000-000000000013', 'backtest.create',  'Run Backtest',        'Execute strategy backtests',                    'backtest',  'create'),
  ('pm000001-0000-4000-8000-000000000014', 'user.manage',      'Manage Users',        'Create, update, suspend users',                 'user',      'manage'),
  ('pm000001-0000-4000-8000-000000000015', 'alert.create',     'Create Alert',        'Set price and condition alerts',                'alert',     'create')
ON CONFLICT DO NOTHING;

-- screener_templates (system-provided)
INSERT INTO screener_templates (id, tenant_id, user_id, name, description, is_public, is_system, category, filters, sort_by, sort_order, columns, use_count)
VALUES
  ('st000001-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'Value Stocks', 'Stocks with low P/E and P/B ratios trading below intrinsic value',
   TRUE, TRUE, 'Value Investing',
   '[{"field":"financial_ratios.pe_ratio","op":"between","min":5,"max":20},{"field":"financial_ratios.pb_ratio","op":"lt","value":2},{"field":"financial_ratios.roe","op":"gt","value":0.15}]',
   'financial_ratios.pe_ratio', 'asc',
   ARRAY['ticker','name','sector','pe_ratio','pb_ratio','roe','dividend_yield','market_cap'],
   2450),

  ('st000001-0000-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'High Dividend Yield', 'Stocks with dividend yield above 3% and sustainable payout',
   TRUE, TRUE, 'Income Investing',
   '[{"field":"financial_ratios.dividend_yield","op":"gte","value":0.03},{"field":"financial_ratios.payout_ratio","op":"lt","value":0.8},{"field":"financial_ratios.debt_to_equity","op":"lt","value":1.5}]',
   'financial_ratios.dividend_yield', 'desc',
   ARRAY['ticker','name','sector','dividend_yield','payout_ratio','debt_to_equity','eps_diluted'],
   1876),

  ('st000001-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'Quality Growth', 'High ROE, revenue growth > 15% with manageable debt',
   TRUE, TRUE, 'Growth Investing',
   '[{"field":"financial_ratios.roe","op":"gt","value":0.20},{"field":"financial_ratios.revenue_growth_yoy","op":"gt","value":0.15},{"field":"financial_ratios.debt_to_equity","op":"lt","value":1.0}]',
   'financial_ratios.revenue_growth_yoy', 'desc',
   ARRAY['ticker','name','sector','roe','revenue_growth_yoy','eps_growth_yoy','pe_ratio'],
   3210),

  ('st000001-0000-4000-8000-000000000004', 'f0000000-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000003',
   'IT Sector Momentum', 'IT stocks with strong earnings growth',
   TRUE, FALSE, 'Sector',
   '[{"field":"symbols.sector","op":"eq","value":"Information Technology"},{"field":"financial_ratios.earnings_growth_yoy","op":"gt","value":0.10}]',
   'financial_ratios.earnings_growth_yoy', 'desc',
   ARRAY['ticker','name','market_cap','pe_ratio','earnings_growth_yoy','roe'],
   891)
ON CONFLICT DO NOTHING;

-- screener_filters
INSERT INTO screener_filters (id, screener_template_id, field_name, operator, value_min, value_max, value_text)
VALUES
  ('sf000001-0000-4000-8000-000000000001', 'st000001-0000-4000-8000-000000000001', 'financial_ratios.pe_ratio',  'between', 5,    20,   NULL),
  ('sf000001-0000-4000-8000-000000000002', 'st000001-0000-4000-8000-000000000001', 'financial_ratios.pb_ratio',  'lt',      NULL, 2,    NULL),
  ('sf000001-0000-4000-8000-000000000003', 'st000001-0000-4000-8000-000000000001', 'financial_ratios.roe',       'gt',      0.15, NULL, NULL),
  ('sf000001-0000-4000-8000-000000000004', 'st000001-0000-4000-8000-000000000002', 'financial_ratios.dividend_yield', 'gte', 0.03, NULL, NULL),
  ('sf000001-0000-4000-8000-000000000005', 'st000001-0000-4000-8000-000000000002', 'financial_ratios.payout_ratio',   'lt',  NULL, 0.8, NULL),
  ('sf000001-0000-4000-8000-000000000006', 'st000001-0000-4000-8000-000000000003', 'financial_ratios.roe',            'gt',  0.20, NULL, NULL),
  ('sf000001-0000-4000-8000-000000000007', 'st000001-0000-4000-8000-000000000003', 'financial_ratios.revenue_growth_yoy', 'gt', 0.15, NULL, NULL),
  ('sf000001-0000-4000-8000-000000000008', 'st000001-0000-4000-8000-000000000004', 'symbols.sector',                  'eq',  NULL, NULL, 'Information Technology')
ON CONFLICT DO NOTHING;

-- saved_screeners
INSERT INTO saved_screeners (id, user_id, template_id, name, last_run_at, result_count)
VALUES
  ('ss000001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001', 'st000001-0000-4000-8000-000000000001', 'My Value Screen',       NOW() - INTERVAL '2 hours',   47),
  ('ss000001-0000-4000-8000-000000000002', 'a1b2c3d4-0001-4000-8000-000000000001', 'st000001-0000-4000-8000-000000000002', 'Dividend Tracker',      NOW() - INTERVAL '1 day',     28),
  ('ss000001-0000-4000-8000-000000000003', 'a1b2c3d4-0001-4000-8000-000000000003', 'st000001-0000-4000-8000-000000000003', 'Quality Growth Watch',  NOW() - INTERVAL '3 hours',   62),
  ('ss000001-0000-4000-8000-000000000004', 'a1b2c3d4-0001-4000-8000-000000000008', 'st000001-0000-4000-8000-000000000004', 'IT Momentum Monitor',   NOW() - INTERVAL '30 minutes', 15)
ON CONFLICT DO NOTHING;
