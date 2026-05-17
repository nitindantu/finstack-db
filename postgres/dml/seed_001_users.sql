-- ============================================================
-- Seed Data: users
-- ============================================================

INSERT INTO users (id, tenant_id, email, password_hash, full_name, phone, email_verified, phone_verified, status, plan_type, login_count, metadata)
VALUES
  ('a1b2c3d4-0001-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001', 'rahul.sharma@example.com',   '$2b$12$KIXrandom1hashedpassword1', 'Rahul Sharma',     '+919876543210', TRUE,  TRUE,  'active',    'premium',    142, '{"source":"web","ref":"google"}'),
  ('a1b2c3d4-0001-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000001', 'priya.mehta@example.com',    '$2b$12$KIXrandom2hashedpassword2', 'Priya Mehta',      '+919812345678', TRUE,  FALSE, 'active',    'basic',       38, '{"source":"app","ref":"organic"}'),
  ('a1b2c3d4-0001-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000001', 'amit.patel@example.com',     '$2b$12$KIXrandom3hashedpassword3', 'Amit Patel',       '+919898765432', TRUE,  TRUE,  'active',    'enterprise', 987, '{"source":"web","ref":"referral","ref_id":"a1b2c3d4-0001-4000-8000-000000000001"}'),
  ('a1b2c3d4-0001-4000-8000-000000000004', 'f0000000-0000-4000-8000-000000000001', 'sunita.rao@example.com',     '$2b$12$KIXrandom4hashedpassword4', 'Sunita Rao',       '+919765432109', TRUE,  TRUE,  'active',    'premium',     72, '{"source":"app"}'),
  ('a1b2c3d4-0001-4000-8000-000000000005', 'f0000000-0000-4000-8000-000000000002', 'vikram.gupta@example.com',   '$2b$12$KIXrandom5hashedpassword5', 'Vikram Gupta',     '+919654321098', TRUE,  FALSE, 'active',    'free',        12, '{"source":"web"}'),
  ('a1b2c3d4-0001-4000-8000-000000000006', 'f0000000-0000-4000-8000-000000000002', 'deepa.iyer@example.com',     '$2b$12$KIXrandom6hashedpassword6', 'Deepa Iyer',       '+919543210987', TRUE,  TRUE,  'active',    'basic',       55, '{"source":"web"}'),
  ('a1b2c3d4-0001-4000-8000-000000000007', 'f0000000-0000-4000-8000-000000000002', 'rohit.verma@example.com',    '$2b$12$KIXrandom7hashedpassword7', 'Rohit Verma',      '+919432109876', FALSE, FALSE, 'inactive',  'free',         3, '{"source":"app"}'),
  ('a1b2c3d4-0001-4000-8000-000000000008', 'f0000000-0000-4000-8000-000000000003', 'kavita.singh@example.com',   '$2b$12$KIXrandom8hashedpassword8', 'Kavita Singh',     '+919321098765', TRUE,  TRUE,  'active',    'enterprise', 203, '{"source":"web","firm":"HedgeCo"}'),
  ('a1b2c3d4-0001-4000-8000-000000000009', 'f0000000-0000-4000-8000-000000000003', 'suresh.kumar@example.com',   '$2b$12$KIXrandom9hashedpassword9', 'Suresh Kumar',     '+919210987654', TRUE,  FALSE, 'active',    'premium',     91, '{"source":"referral"}'),
  ('a1b2c3d4-0001-4000-8000-000000000010', 'f0000000-0000-4000-8000-000000000003', 'ananya.krishnan@example.com','$2b$12$KIXrandom0hashedpassword0', 'Ananya Krishnan',  '+919109876543', TRUE,  TRUE,  'active',    'basic',       27, '{"source":"web"}'),
  ('a1b2c3d4-0001-4000-8000-000000000011', 'f0000000-0000-4000-8000-000000000001', 'manoj.joshi@example.com',    '$2b$12$KIXrandoma1hashedpass1',   'Manoj Joshi',      '+919099887766', TRUE,  TRUE,  'active',    'premium',    156, '{"source":"web"}'),
  ('a1b2c3d4-0001-4000-8000-000000000012', 'f0000000-0000-4000-8000-000000000001', 'nisha.agarwal@example.com',  '$2b$12$KIXrandomb2hashedpass2',   'Nisha Agarwal',    '+919088776655', TRUE,  FALSE, 'suspended', 'basic',       18, '{"reason":"tos_violation"}'),
  ('a1b2c3d4-0001-4000-8000-000000000013', 'f0000000-0000-4000-8000-000000000004', 'arjun.nair@example.com',     '$2b$12$KIXrandomc3hashedpass3',   'Arjun Nair',       '+919077665544', TRUE,  TRUE,  'active',    'enterprise', 445, '{"source":"direct"}'),
  ('a1b2c3d4-0001-4000-8000-000000000014', 'f0000000-0000-4000-8000-000000000004', 'pooja.bansal@example.com',   '$2b$12$KIXrandomd4hashedpass4',   'Pooja Bansal',     '+919066554433', TRUE,  TRUE,  'active',    'free',         7, '{"source":"app"}'),
  ('a1b2c3d4-0001-4000-8000-000000000015', 'f0000000-0000-4000-8000-000000000004', 'kiran.reddy@example.com',    '$2b$12$KIXrandome5hashedpass5',   'Kiran Reddy',      '+919055443322', TRUE,  TRUE,  'active',    'premium',     84, '{"source":"web","ref":"linkedin"}')
ON CONFLICT DO NOTHING;
