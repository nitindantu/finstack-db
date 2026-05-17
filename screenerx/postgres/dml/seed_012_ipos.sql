-- Seed: ipos — upcoming and recently listed IPOs
SET search_path TO screenerx, public;

INSERT INTO screenerx.ipos
  (company_name, ticker, exchange, issue_size_cr, price_band_low, price_band_high, lot_size,
   open_date, close_date, allotment_date, listing_date, listing_price, gmp, status, category,
   registrar, subscription_times, min_investment)
VALUES
  ('Bajaj Housing Finance Ltd', 'BAJAJHFL', 'NSE', 6560.00, 66.00, 70.00, 214,
   CURRENT_DATE + 3, CURRENT_DATE + 5, CURRENT_DATE + 8, CURRENT_DATE + 11,
   NULL, 8.00, 'open', 'Housing Finance',
   'KFin Technologies', NULL, 14980.00),

  ('Ola Electric Mobility Ltd', 'OLAELEC', 'NSE', 5500.00, 72.00, 76.00, 197,
   CURRENT_DATE + 5, CURRENT_DATE + 7, CURRENT_DATE + 10, CURRENT_DATE + 13,
   NULL, 12.00, 'upcoming', 'Electric Vehicles',
   'Link Intime India', NULL, 14972.00),

  ('FirstCry (Brainbees Solutions)', 'FIRSTCRY', 'NSE', 4193.73, 440.00, 465.00, 32,
   CURRENT_DATE + 8, CURRENT_DATE + 11, CURRENT_DATE + 14, CURRENT_DATE + 17,
   NULL, 22.00, 'upcoming', 'Baby & Kids Retail',
   'MUFG Intime India', NULL, 14880.00),

  ('Emcure Pharmaceuticals Ltd', 'EMCURE', 'NSE', 1952.03, 960.00, 1008.00, 14,
   CURRENT_DATE + 17, CURRENT_DATE + 19, CURRENT_DATE + 22, CURRENT_DATE + 25,
   NULL, 5.00, 'upcoming', 'Pharmaceuticals',
   'KFin Technologies', NULL, 14112.00),

  ('Niva Bupa Health Insurance', 'NIVABUPA', 'NSE', 3000.00, 70.00, 74.00, 202,
   CURRENT_DATE + 21, CURRENT_DATE + 23, CURRENT_DATE + 26, CURRENT_DATE + 29,
   NULL, 3.00, 'upcoming', 'Health Insurance',
   'Link Intime India', NULL, 14948.00),

  ('Hyundai Motor India Ltd', 'HYUNDAI', 'NSE', 27870.16, 1865.00, 1960.00, 7,
   CURRENT_DATE - 30, CURRENT_DATE - 28, CURRENT_DATE - 25, CURRENT_DATE - 20,
   1934.00, NULL, 'listed', 'Automobiles',
   'KFin Technologies', 2.37, 13720.00),

  ('Swiggy Ltd', 'SWIGGY', 'NSE', 11327.43, 371.00, 390.00, 38,
   CURRENT_DATE - 14, CURRENT_DATE - 12, CURRENT_DATE - 9, CURRENT_DATE - 5,
   412.00, NULL, 'listed', 'Food Delivery',
   'Link Intime India', 3.59, 14820.00)

ON CONFLICT DO NOTHING;
