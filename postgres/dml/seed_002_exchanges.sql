-- ============================================================
-- Seed Data: exchanges
-- ============================================================

INSERT INTO exchanges (id, code, name, country, currency, timezone, trading_hours, is_active, metadata)
VALUES
  ('e0000000-0000-4000-8000-000000000001', 'NSE',    'National Stock Exchange of India',       'IN', 'INR', 'Asia/Kolkata',
   '{"weekdays":{"open":"09:15","close":"15:30"},"pre_open":{"open":"09:00","close":"09:08"},"post_close":{"open":"15:40","close":"16:00"}}',
   TRUE, '{"mic":"XNSE","country_code":"IN","website":"https://www.nseindia.com"}'),

  ('e0000000-0000-4000-8000-000000000002', 'BSE',    'Bombay Stock Exchange',                  'IN', 'INR', 'Asia/Kolkata',
   '{"weekdays":{"open":"09:15","close":"15:30"},"pre_open":{"open":"09:00","close":"09:08"}}',
   TRUE, '{"mic":"XBOM","country_code":"IN","website":"https://www.bseindia.com","established":1875}'),

  ('e0000000-0000-4000-8000-000000000003', 'NYSE',   'New York Stock Exchange',                'US', 'USD', 'America/New_York',
   '{"weekdays":{"open":"09:30","close":"16:00"},"pre_market":{"open":"04:00","close":"09:30"},"after_market":{"open":"16:00","close":"20:00"}}',
   TRUE, '{"mic":"XNYS","website":"https://www.nyse.com"}'),

  ('e0000000-0000-4000-8000-000000000004', 'NASDAQ', 'NASDAQ Stock Market',                   'US', 'USD', 'America/New_York',
   '{"weekdays":{"open":"09:30","close":"16:00"},"pre_market":{"open":"04:00","close":"09:30"},"after_market":{"open":"16:00","close":"20:00"}}',
   TRUE, '{"mic":"XNAS","website":"https://www.nasdaq.com"}'),

  ('e0000000-0000-4000-8000-000000000005', 'MCX',    'Multi Commodity Exchange of India',      'IN', 'INR', 'Asia/Kolkata',
   '{"weekdays":{"open":"09:00","close":"23:30"},"international_commodities":{"open":"09:00","close":"23:30"}}',
   TRUE, '{"mic":"XIMC","commodity_exchange":true}'),

  ('e0000000-0000-4000-8000-000000000006', 'LSE',    'London Stock Exchange',                  'GB', 'GBP', 'Europe/London',
   '{"weekdays":{"open":"08:00","close":"16:30"}}',
   TRUE, '{"mic":"XLON","website":"https://www.londonstockexchange.com"}'),

  ('e0000000-0000-4000-8000-000000000007', 'SGX',    'Singapore Exchange',                     'SG', 'SGD', 'Asia/Singapore',
   '{"weekdays":{"morning":{"open":"09:00","close":"12:00"},"afternoon":{"open":"13:00","close":"17:00"}}}',
   TRUE, '{"mic":"XSES","website":"https://www.sgx.com"}'),

  ('e0000000-0000-4000-8000-000000000008', 'NCDEX',  'National Commodity & Derivatives Exchange','IN', 'INR', 'Asia/Kolkata',
   '{"weekdays":{"open":"09:00","close":"17:00"}}',
   TRUE, '{"commodity_exchange":true}')
ON CONFLICT DO NOTHING;
