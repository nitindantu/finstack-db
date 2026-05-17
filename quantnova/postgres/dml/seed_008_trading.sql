-- ============================================================
-- Seed Data: brokers, broker_accounts, strategies, backtests
-- ============================================================

-- brokers
INSERT INTO brokers (id, name, code, api_base_url, supported_exchanges, features, is_active)
VALUES
  ('br000001-0000-4000-8000-000000000001', 'Zerodha',          'ZERODHA',  'https://api.kite.trade',           ARRAY['NSE','BSE','MCX','NCDEX'],
   '{"gtc":false,"amo":true,"options":true,"futures":true,"bracket_order":true,"cover_order":true,"basket_order":true,"sip":false}', TRUE),
  ('br000001-0000-4000-8000-000000000002', 'Upstox',           'UPSTOX',   'https://api.upstox.com/v2',        ARRAY['NSE','BSE','MCX'],
   '{"gtc":true,"amo":true,"options":true,"futures":true,"bracket_order":false,"cover_order":false}', TRUE),
  ('br000001-0000-4000-8000-000000000003', 'Angel One',        'ANGEL',    'https://apiconnect.angelbroking.com', ARRAY['NSE','BSE','MCX','NCDEX'],
   '{"gtc":false,"amo":true,"options":true,"futures":true,"smartapi":true}', TRUE),
  ('br000001-0000-4000-8000-000000000004', 'HDFC Securities',  'HDFC_SEC', 'https://api.hdfcsec.com',          ARRAY['NSE','BSE','MCX'],
   '{"3in1":true,"demat_integrated":true,"options":true}', TRUE),
  ('br000001-0000-4000-8000-000000000005', 'Interactive Brokers','IBKR',   'https://api.ibkr.com',             ARRAY['NYSE','NASDAQ','LSE','SGX'],
   '{"global_markets":true,"options":true,"futures":true,"forex":true,"fractional_shares":true}', TRUE)
ON CONFLICT DO NOTHING;

-- broker_accounts
INSERT INTO broker_accounts (id, user_id, broker_id, account_id, account_type, is_active, balance, margin_available)
VALUES
  ('ba000001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001', 'br000001-0000-4000-8000-000000000001', 'ZX1234567', 'trading',   TRUE, 125000.00, 250000.00),
  ('ba000001-0000-4000-8000-000000000002', 'a1b2c3d4-0001-4000-8000-000000000001', 'br000001-0000-4000-8000-000000000001', 'DX1234567', 'demat',     TRUE,      0.00,      0.00),
  ('ba000001-0000-4000-8000-000000000003', 'a1b2c3d4-0001-4000-8000-000000000003', 'br000001-0000-4000-8000-000000000001', 'ZX9876543', 'trading',   TRUE, 456000.00, 912000.00),
  ('ba000001-0000-4000-8000-000000000004', 'a1b2c3d4-0001-4000-8000-000000000008', 'br000001-0000-4000-8000-000000000002', 'UX5551234', 'trading',   TRUE, 892000.00,1784000.00),
  ('ba000001-0000-4000-8000-000000000005', 'a1b2c3d4-0001-4000-8000-000000000013', 'br000001-0000-4000-8000-000000000005', 'U8765432',  'trading',   TRUE,1200000.00,2400000.00)
ON CONFLICT DO NOTHING;

-- strategies
INSERT INTO strategies (id, user_id, name, description, strategy_type, universe_filter, entry_conditions, exit_conditions, position_sizing, risk_management, is_active, is_public)
VALUES
  ('str00001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'NIFTY50 Momentum', 'Buy top performers in NIFTY 50 based on 3-month momentum, hold 1 month',
   'momentum',
   '{"index":"NIFTY50","instrument_type":"equity"}',
   '[{"indicator":"momentum_3m","op":"top_percentile","value":20}]',
   '[{"indicator":"momentum_3m","op":"lt","value":50},{"time_based":"30_days"}]',
   '{"method":"equal_weight","max_positions":10,"per_position_pct":10}',
   '{"stop_loss_pct":7,"max_daily_loss_pct":2,"max_drawdown_pct":20}',
   TRUE, TRUE),

  ('str00001-0000-4000-8000-000000000002', 'a1b2c3d4-0001-4000-8000-000000000003',
   'Mean Reversion IT', 'Buy oversold IT stocks on RSI < 30, exit on RSI > 60',
   'mean_reversion',
   '{"sector":"Information Technology","market_cap":"large_cap"}',
   '[{"indicator":"RSI_14","op":"lt","value":30},{"indicator":"200_DMA","op":"price_above","buffer_pct":5}]',
   '[{"indicator":"RSI_14","op":"gt","value":60}]',
   '{"method":"fixed_amount","per_trade_inr":50000}',
   '{"stop_loss_pct":5,"take_profit_pct":15}',
   TRUE, FALSE),

  ('str00001-0000-4000-8000-000000000003', 'a1b2c3d4-0001-4000-8000-000000000008',
   'Earnings Surprise Alpha', 'Buy stocks with positive EPS surprise > 5%, hold for 10 days',
   'factor',
   '{"instrument_type":"equity","exchange":"NSE"}',
   '[{"event":"earnings_release","condition":"eps_surprise_pct > 5"},{"indicator":"volume","op":"gt_avg","multiplier":2}]',
   '[{"time_based":"10_days"},{"indicator":"stop_loss","value_pct":4}]',
   '{"method":"pct_equity","per_trade_pct":3,"max_positions":8}',
   '{"stop_loss_pct":4,"trailing_stop_pct":3}',
   TRUE, FALSE)
ON CONFLICT DO NOTHING;

-- backtests
INSERT INTO backtests (id, strategy_id, user_id, name, start_date, end_date, initial_capital, commission_rate, slippage_rate, status)
VALUES
  ('bt000001-0000-4000-8000-000000000001', 'str00001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'NIFTY50 Momentum 5Y', '2020-01-01', '2025-12-31', 1000000.00, 0.0003, 0.0001, 'completed'),
  ('bt000001-0000-4000-8000-000000000002', 'str00001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001',
   'NIFTY50 Momentum 10Y', '2015-01-01', '2025-12-31', 1000000.00, 0.0003, 0.0001, 'completed'),
  ('bt000001-0000-4000-8000-000000000003', 'str00001-0000-4000-8000-000000000002', 'a1b2c3d4-0001-4000-8000-000000000003',
   'Mean Reversion IT 3Y', '2022-01-01', '2025-06-30', 500000.00, 0.0003, 0.0001, 'completed'),
  ('bt000001-0000-4000-8000-000000000004', 'str00001-0000-4000-8000-000000000003', 'a1b2c3d4-0001-4000-8000-000000000008',
   'Earnings Surprise 2Y', '2023-01-01', '2025-12-31', 2000000.00, 0.0005, 0.0002, 'running')
ON CONFLICT DO NOTHING;

-- backtest_results
INSERT INTO backtest_results (id, backtest_id, total_return, annualized_return, sharpe_ratio, sortino_ratio, max_drawdown, max_drawdown_duration, win_rate, profit_factor, total_trades, best_trade_pct, worst_trade_pct)
VALUES
  ('br100001-0000-4000-8000-000000000001', 'bt000001-0000-4000-8000-000000000001', 2.8453, 0.2174, 1.4523, 2.1234, -0.2134, 112, 0.6234, 2.4512, 342, 0.4523, -0.1234),
  ('br100001-0000-4000-8000-000000000002', 'bt000001-0000-4000-8000-000000000002', 8.1245, 0.2456, 1.3823, 2.0123, -0.2845, 187, 0.5978, 2.1234, 678, 0.5123, -0.1892),
  ('br100001-0000-4000-8000-000000000003', 'bt000001-0000-4000-8000-000000000003', 0.4523, 0.1345, 0.9823, 1.2345, -0.1523, 45,  0.5823, 1.7823, 187, 0.2912, -0.1023)
ON CONFLICT DO NOTHING;

-- alerts
INSERT INTO alerts (id, user_id, symbol_id, alert_type, condition, notification_channels, is_active, triggered_count)
VALUES
  ('al000001-0000-4000-8000-000000000001', 'a1b2c3d4-0001-4000-8000-000000000001', 's0000000-0000-4000-8000-000000000001', 'price',
   '{"field":"ltp","op":"gte","value":3000}', ARRAY['push','in_app'], TRUE, 0),
  ('al000001-0000-4000-8000-000000000002', 'a1b2c3d4-0001-4000-8000-000000000001', 's0000000-0000-4000-8000-000000000001', 'price',
   '{"field":"ltp","op":"lte","value":2800}', ARRAY['push','email','in_app'], TRUE, 0),
  ('al000001-0000-4000-8000-000000000003', 'a1b2c3d4-0001-4000-8000-000000000003', 's0000000-0000-4000-8000-000000000002', 'price',
   '{"field":"ltp","op":"gte","value":4000}', ARRAY['push','in_app'], TRUE, 2),
  ('al000001-0000-4000-8000-000000000004', 'a1b2c3d4-0001-4000-8000-000000000008', 's0000000-0000-4000-8000-000000000010', 'technical',
   '{"indicator":"RSI_14","op":"lt","value":30}', ARRAY['push','in_app'], TRUE, 1)
ON CONFLICT DO NOTHING;
