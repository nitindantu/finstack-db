-- Seed: fii_dii_activity — last 10 days of FII/DII data
SET search_path TO screenerx, public;

INSERT INTO screenerx.fii_dii_activity
  (activity_date, fii_buy, fii_sell, dii_buy, dii_sell, segment, source)
VALUES
  (CURRENT_DATE - 1,  8456.23,  6110.56,  5234.78,  6469.34, 'equity', 'NSE'),
  (CURRENT_DATE - 2,  5234.67,  6802.56,  7456.89,  5111.22, 'equity', 'NSE'),
  (CURRENT_DATE - 3,  9678.45,  6221.67,  4567.34,  3332.78, 'equity', 'NSE'),
  (CURRENT_DATE - 4,  4321.89,  6667.56,  8234.56,  4777.78, 'equity', 'NSE'),
  (CURRENT_DATE - 5,  7456.34,  6221.78,  5678.90,  6246.01, 'equity', 'NSE'),
  (CURRENT_DATE - 6,  6789.12,  5345.67,  4321.45,  5234.56, 'equity', 'NSE'),
  (CURRENT_DATE - 7,  3456.78,  7234.56,  9123.45,  6789.12, 'equity', 'NSE'),
  (CURRENT_DATE - 8,  8901.23,  5678.90,  3456.78,  4567.89, 'equity', 'NSE'),
  (CURRENT_DATE - 9,  5678.90,  4321.23,  6789.12,  5678.45, 'equity', 'NSE'),
  (CURRENT_DATE - 10, 7234.56,  8901.23,  5432.10,  3456.78, 'equity', 'NSE')

ON CONFLICT (activity_date, segment) DO UPDATE SET
  fii_buy    = EXCLUDED.fii_buy,
  fii_sell   = EXCLUDED.fii_sell,
  dii_buy    = EXCLUDED.dii_buy,
  dii_sell   = EXCLUDED.dii_sell,
  updated_at = NOW();
