# ScreenerX Redis Key Schema Reference

## Overview

Redis is used for:
1. Real-time market data caching (latest prices, order books)
2. Session management
3. Rate limiting
4. Screener result caching
5. Pub/Sub for WebSocket fan-out
6. Sorted sets for rankings and leaderboards

All keys follow the pattern: `{namespace}:{entity_type}:{identifier}`

---

## 1. Market Data

### Latest Price Hash
```
Key:     market:price:{symbol_id}
Type:    Hash
Fields:
  ltp          — Last Traded Price (string, decimal)
  open         — Day open price
  high         — Day high price
  low          — Day low price
  close        — Previous close price
  volume       — Day volume (integer)
  bid          — Best bid price
  ask          — Best ask price
  bid_size     — Bid quantity
  ask_size     — Ask quantity
  change       — Price change vs prev close
  change_pct   — Percentage change
  timestamp    — Exchange timestamp (ISO 8601)
  exchange     — Exchange code (NSE/BSE)
TTL:     300 seconds (5 minutes; refreshed on every tick)
Example: market:price:s0000000-0000-4000-8000-000000000001
```

### Order Book Snapshot
```
Key:     market:orderbook:{symbol_id}:{side}
Type:    Sorted Set
Score:   Price level (numeric)
Member:  JSON string {"price": 2958.30, "qty": 1500, "orders": 12}
TTL:     60 seconds
Note:    'bid' side sorted DESC (highest bid first); 'ask' sorted ASC
Example: market:orderbook:s0000000-0000-4000-8000-000000000001:bid
```

### OHLCV Bar Cache (Latest Candle)
```
Key:     market:candle:{symbol_id}:{timeframe}
Type:    Hash
Fields:
  open, high, low, close, volume, vwap, timestamp
TTL:     Matches timeframe (1m → 60s, 5m → 300s, 1h → 3600s)
Example: market:candle:s0000000-0000-4000-8000-000000000001:5m
```

### Market Status
```
Key:     market:status:{exchange_code}
Type:    Hash
Fields:
  status       — open | closed | pre_open | post_close
  opens_at     — ISO timestamp of next open
  closes_at    — ISO timestamp of next close
  session      — morning | afternoon | normal
TTL:     3600 seconds
Example: market:status:NSE
```

---

## 2. Session Management

### User Session
```
Key:     session:{token_hash}
Type:    Hash
Fields:
  user_id      — UUID
  tenant_id    — UUID
  email        — User email
  plan_type    — free | basic | premium | enterprise
  roles        — JSON array of role names
  device_id    — Device fingerprint
  ip_address   — IPv4/IPv6
  created_at   — ISO timestamp
  expires_at   — ISO timestamp
TTL:     Sliding, max 86400 seconds (24h); refreshed on activity
Example: session:8f14e45f-ceea-367f-a027-7a9b0b3a1c2d
```

### Active Sessions Per User (for multi-device logout)
```
Key:     user:sessions:{user_id}
Type:    Set
Members: token_hash strings
TTL:     86400 seconds
Example: user:sessions:a1b2c3d4-0001-4000-8000-000000000001
```

---

## 3. Rate Limiting

### Sliding Window Rate Limiter
```
Key:     ratelimit:{user_id}:{endpoint}
Type:    Sorted Set
Score:   Timestamp (Unix ms)
Member:  Unique request ID (UUID)
TTL:     Window size in seconds (e.g. 60 for per-minute limits)
Usage:   ZADD + ZREMRANGEBYSCORE + ZCARD
Example: ratelimit:a1b2c3d4-0001-4000-8000-000000000001:screener/execute
```

### API Key Rate Limiter
```
Key:     ratelimit:apikey:{key_hash}:{window}
Type:    String (counter)
TTL:     Window duration
Example: ratelimit:apikey:abc123:60
```

### IP-Based Rate Limiter (unauthenticated endpoints)
```
Key:     ratelimit:ip:{ip_address}:{endpoint}
Type:    String (INCR counter)
TTL:     60 seconds
Example: ratelimit:ip:203.0.113.42:auth/login
```

---

## 4. Screener Cache

### Screener Result Cache
```
Key:     screener:cache:{screener_hash}
Type:    String (JSON serialized)
Value:   {"symbol_ids": [...], "results": [...], "executed_at": "...", "result_count": 47}
TTL:     300 seconds (5 minutes for live data)
Note:    Hash = SHA-256 of canonical filter JSON
Example: screener:cache:7f83b165-3699-4b38-8c84-12e59c4b4e25
```

### Active Screener Executions (for deduplication)
```
Key:     screener:running:{user_id}:{screener_id}
Type:    String
Value:   "1"
TTL:     30 seconds (prevents duplicate concurrent runs)
Example: screener:running:a1b2c3d4-0001-4000-8000-000000000001:st000001-0000-4000-8000-000000000001
```

---

## 5. Watchlist

### User Watchlist (sorted set for ordered display)
```
Key:     watchlist:{user_id}:{watchlist_id}
Type:    Sorted Set
Score:   sort_order (integer)
Member:  symbol_id (UUID string)
TTL:     None (persistent; invalidated on write)
Example: watchlist:a1b2c3d4-0001-4000-8000-000000000001:wl000001-0000-4000-8000-000000000001
```

---

## 6. Portfolio

### Portfolio NAV
```
Key:     portfolio:nav:{portfolio_id}:{date}
Type:    String (decimal)
Value:   "2345678.50"
TTL:     86400 seconds (1 day)
Example: portfolio:nav:pf000001-0000-4000-8000-000000000001:2026-05-14
```

### Portfolio Positions Cache
```
Key:     portfolio:positions:{portfolio_id}
Type:    Hash
Fields:  {symbol_id} → JSON string {"qty": 150, "avg_cost": 2456.50, "current_price": 2958.30, "pnl": 75270}
TTL:     300 seconds (5 minutes; refreshed when prices update)
Example: portfolio:portfolio:positions:pf000001-0000-4000-8000-000000000001
```

---

## 7. Alert State

### Alert Cooldown (prevent re-firing within window)
```
Key:     alert:cooldown:{alert_id}
Type:    String
Value:   "triggered"
TTL:     cooldown_seconds (e.g. 3600 for hourly alerts)
Example: alert:cooldown:al000001-0000-4000-8000-000000000001
```

---

## 8. Pub/Sub Channels

### Live Market Tick (publish on each tick)
```
Channel: ticks:{exchange_code}:{symbol_id}
Message: JSON {"symbol_id": "...", "price": 2958.30, "volume": 500, "timestamp": "..."}
```

### Alert Fired
```
Channel: alerts:{user_id}
Message: JSON {"alert_id": "...", "symbol_id": "...", "message": "...", "triggered_at": "..."}
```

### Order Status Update
```
Channel: orders:{user_id}
Message: JSON {"order_id": "...", "status": "filled", "fill_price": 2960.00, "fill_qty": 50}
```

### Portfolio Update
```
Channel: portfolio:{portfolio_id}
Message: JSON {"portfolio_id": "...", "total_value": 2345678.50, "day_pnl": 12450.00}
```

---

## 9. Leaderboards & Rankings

### Top Gainers (refreshed every minute)
```
Key:     rankings:gainers:{exchange_code}:{date}
Type:    Sorted Set
Score:   change_pct (float)
Member:  symbol_id
TTL:     86400 seconds
```

### Top Losers
```
Key:     rankings:losers:{exchange_code}:{date}
Type:    Sorted Set
Score:   change_pct (float, ascending = most negative first)
Member:  symbol_id
TTL:     86400 seconds
```

### Most Active by Volume
```
Key:     rankings:volume:{exchange_code}:{date}
Type:    Sorted Set
Score:   volume (integer)
Member:  symbol_id
TTL:     86400 seconds
```

---

## 10. Feature Flags

```
Key:     feature:{tenant_id}:{feature_name}
Type:    String
Value:   "on" | "off" | JSON config
TTL:     None (managed by admin)
Example: feature:f0000000-0000-4000-8000-000000000001:ai_recommendations
```

---

## Lua Scripts

### Atomic Rate Limit Check (sliding window)
```lua
-- Key: ratelimit:{user_id}:{endpoint}
-- ARGV[1] = current_time_ms
-- ARGV[2] = window_ms  
-- ARGV[3] = limit
-- ARGV[4] = request_id
-- Returns: 1 if allowed, 0 if rate-limited

local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local limit = tonumber(ARGV[3])
local req_id = ARGV[4]

redis.call('ZREMRANGEBYSCORE', key, 0, now - window)
local count = redis.call('ZCARD', key)
if count < limit then
    redis.call('ZADD', key, now, req_id)
    redis.call('PEXPIRE', key, window)
    return 1
end
return 0
```

### Atomic Screener Cache Get-or-Lock
```lua
-- Returns cached result if exists, otherwise sets a lock
-- KEYS[1] = screener:cache:{hash}
-- KEYS[2] = screener:lock:{hash}
-- ARGV[1] = lock_ttl_ms

local cached = redis.call('GET', KEYS[1])
if cached then
    return cached
end
local locked = redis.call('SET', KEYS[2], '1', 'PX', tonumber(ARGV[1]), 'NX')
if locked then
    return nil  -- caller should execute query and populate cache
else
    return '__LOCKED__'  -- caller should wait and retry
end
```
