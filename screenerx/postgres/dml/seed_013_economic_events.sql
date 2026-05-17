-- Seed: economic_events — upcoming macro calendar
SET search_path TO screenerx, public;

INSERT INTO screenerx.economic_events
  (event_name, country, event_date, actual_value, forecast_value, previous_value, importance, currency_impact)
VALUES
  ('India CPI Inflation (YoY)', 'IN',
   CURRENT_TIMESTAMP + INTERVAL '2 hours',
   4.83, 4.90, 5.10, 'high', ARRAY['INR']),

  ('US Federal Reserve FOMC Minutes', 'US',
   CURRENT_TIMESTAMP + INTERVAL '10 hours',
   NULL, NULL, NULL, 'high', ARRAY['USD','INR']),

  ('India WPI Inflation', 'IN',
   CURRENT_TIMESTAMP + INTERVAL '1 day 20 hours',
   NULL, 0.70, 0.53, 'medium', ARRAY['INR']),

  ('US Retail Sales (MoM)', 'US',
   CURRENT_TIMESTAMP + INTERVAL '2 days 14 hours',
   NULL, 0.40, 0.70, 'medium', ARRAY['USD']),

  ('ECB Interest Rate Decision', 'EU',
   CURRENT_TIMESTAMP + INTERVAL '3 days 12 hours',
   NULL, NULL, 4.00, 'high', ARRAY['EUR','USD']),

  ('India GDP Growth Rate (QoQ)', 'IN',
   CURRENT_TIMESTAMP + INTERVAL '5 days 8 hours',
   NULL, 6.80, 7.00, 'high', ARRAY['INR']),

  ('US Non-Farm Payrolls', 'US',
   CURRENT_TIMESTAMP + INTERVAL '7 days 14 hours',
   NULL, 185000, 175000, 'high', ARRAY['USD','INR']),

  ('India RBI Policy Meeting', 'IN',
   CURRENT_TIMESTAMP + INTERVAL '10 days 10 hours',
   NULL, NULL, 6.50, 'high', ARRAY['INR']),

  ('US CPI Inflation (YoY)', 'US',
   CURRENT_TIMESTAMP + INTERVAL '12 days 14 hours',
   NULL, 3.40, 3.50, 'high', ARRAY['USD','INR']),

  ('India IIP Data', 'IN',
   CURRENT_TIMESTAMP + INTERVAL '14 days 8 hours',
   NULL, 5.20, 4.90, 'medium', ARRAY['INR'])

ON CONFLICT DO NOTHING;
