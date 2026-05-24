# ScreenerX Redis Key Schema Reference

## Overview

Redis keys in the `screenerx` domain cover:
- Real-time market data (prices, order books, OHLCV candles)
- Screener result caching and execution deduplication
- Watchlist sorted sets
- Portfolio NAV and position caches
- Alert cooldown state
- Market rankings (top gainers, losers, volume)
- WebSocket pub/sub channels
- AI platform caches: market intelligence summaries (2hr TTL), recommendation refresh rate-limiting (v1.3.0)
- **Trading engine** (v1.4.0): live tick pub/sub, order update streaming, RMS kill switch, order dedup, rate limiting

All keys follow: `{namespace}:{entity_type}:{identifier}`

---

## 1. Market Data

### Latest Price Hash
```
Key:     market:price:{symbol_id}
Type:    Hash
Fields:
  ltp, open, high, low, close, volume, bid, ask,
  bid_size, ask_size, change, change_pct, timestamp, exchange
TTL:     300 seconds (refreshed on every tick)
Example: market:price:s0000000-0000-4000-8000-000000000001
```

### Order Book Snapshot
```
Key:     market:orderbook:{symbol_id}:{side}
Type:    Sorted Set
Score:   Price level (numeric)
Member:  JSON {"price": 2958.30, "qty": 1500, "orders": 12}
TTL:     60 seconds
Note:    'bid' sorted DESC; 'ask' sorted ASC
Example: market:orderbook:s0000000-0000-4000-8000-000000000001:bid
```

### OHLCV Bar Cache
```
Key:     market:candle:{symbol_id}:{timeframe}
Type:    Hash
Fields:  open, high, low, close, volume, vwap, timestamp
TTL:     Matches timeframe (1m→60s, 5m→300s, 1h→3600s)
Example: market:candle:s0000000-0000-4000-8000-000000000001:5m
```

### Market Status
```
Key:     market:status:{exchange_code}
Type:    Hash
Fields:  status (open|closed|pre_open|post_close), opens_at, closes_at, session
TTL:     3600 seconds
Example: market:status:NSE
```

---

## 2. Screener Cache

### Screener Result Cache
```
Key:     screener:cache:{screener_hash}
Type:    String (JSON)
Value:   {"symbol_ids": [...], "results": [...], "executed_at": "...", "result_count": 47}
TTL:     300 seconds
Note:    Hash = SHA-256 of canonical filter JSON
Example: screener:cache:7f83b165-3699-4b38-8c84-12e59c4b4e25
```

### Active Screener Execution Lock (deduplication)
```
Key:     screener:running:{user_id}:{screener_id}
Type:    String ("1")
TTL:     30 seconds
Example: screener:running:a1b2c3d4-0001-4000-8000-000000000001:st000001-0000-4000-8000-000000000001
```

---

## 3. Watchlist

### User Watchlist (sorted set for ordered display)
```
Key:     watchlist:{user_id}:{watchlist_id}
Type:    Sorted Set
Score:   sort_order (integer)
Member:  symbol_id (UUID)
TTL:     None (persistent; invalidated on write)
Example: watchlist:a1b2c3d4-0001-4000-8000-000000000001:wl000001-0000-4000-8000-000000000001
```

---

## 4. Portfolio

### Portfolio NAV
```
Key:     portfolio:nav:{portfolio_id}:{date}
Type:    String (decimal)
TTL:     86400 seconds
Example: portfolio:nav:pf000001-0000-4000-8000-000000000001:2026-05-17
```

### Portfolio Positions Cache
```
Key:     portfolio:positions:{portfolio_id}
Type:    Hash
Fields:  {symbol_id} → JSON {"qty": 150, "avg_cost": 2456.50, "current_price": 2958.30, "pnl": 75270}
TTL:     300 seconds
Example: portfolio:positions:pf000001-0000-4000-8000-000000000001
```

---

## 5. Alert State

### Alert Cooldown
```
Key:     alert:cooldown:{alert_id}
Type:    String ("triggered")
TTL:     cooldown_seconds (e.g. 3600 for hourly alerts)
Example: alert:cooldown:al000001-0000-4000-8000-000000000001
```

---

## 6. Market Rankings

### Top Gainers / Losers / Volume
```
Key:     rankings:gainers:{exchange_code}:{date}
Key:     rankings:losers:{exchange_code}:{date}
Key:     rankings:volume:{exchange_code}:{date}
Type:    Sorted Set
Score:   change_pct or volume
Member:  symbol_id
TTL:     86400 seconds
```

---

## 7. Pub/Sub Channels

### Live Market Tick
```
Channel: ticks:{exchange_code}:{symbol_id}
Message: JSON {"symbol_id": "...", "price": 2958.30, "volume": 500, "timestamp": "..."}
```

### Portfolio Update
```
Channel: portfolio:{portfolio_id}
Message: JSON {"portfolio_id": "...", "total_value": 2345678.50, "day_pnl": 12450.00}
```

---

## 8. AI Platform (v1.3.0)

### Market Intelligence Summary Cache
```
Key:     ai:market-intelligence:{summary_type}:{date}
Type:    String (JSON)
Value:   {"content": "...", "model_id": "...", "generatedAt": "...", "disclaimer": "..."}
TTL:     7200 seconds (2 hours)
Example: ai:market-intelligence:daily_brief:2026-05-18
         ai:market-intelligence:sector_rotation:2026-05-18
         ai:market-intelligence:macro_outlook:2026-05-18
Note:    Keyed by type + date. After TTL expiry, next request triggers fresh Claude generation.
```

### Recommendation Refresh Rate Limit
```
Key:     ai:rec-refresh-limit:{user_id}
Type:    String ("1")
TTL:     3600 seconds (1 hour)
Note:    Set when a user triggers /recommendations/refresh. Prevents excessive API usage.
Example: ai:rec-refresh-limit:a1b2c3d4-0001-4000-8000-000000000001
```

### Financial Health Score Cache
```
Key:     ai:health-score:{user_id}
Type:    String (JSON)
Value:   {"compositeScore": 74, "grade": "B", "subScores": {...}, "computedAt": "..."}
TTL:     3600 seconds (1 hour)
Note:    Invalidated immediately when portfolio, goals, or risk profile changes.
Example: ai:health-score:a1b2c3d4-0001-4000-8000-000000000001
```

---

## Trading Engine Keys (v1.4.0) — Redis DB 5

> **Note:** The trading engine uses a dedicated Redis logical DB (DB 5) to avoid key collisions with the main application (DB 0). Celery workers use DB 3 (broker) and DB 4 (results).

### Kill Switch
```
Key:     kill:{user_id}
Type:    String ("1")
TTL:     None (manual deletion only via DELETE /rms/kill-switch)
Note:    Presence of this key blocks ALL order placement for the user.
         Set by POST /rms/kill-switch; removed by DELETE /rms/kill-switch.
Example: kill:a1b2c3d4-0001-4000-8000-000000000001
```

### Order Deduplication
```
Key:     dedup:{user_id}:{broker_account_id}:{symbol}:{side}:{quantity}
Type:    String ("1")
TTL:     2 seconds
Note:    Set atomically (SETNX) before placing an order. Prevents duplicate
         orders from rapid UI double-clicks or network retries within 2 seconds.
Example: dedup:a1b2c3d4:ba001234:INFY:buy:50
```

### Order Rate Limiter
```
Key:     ratelimit:orders:{user_id}
Type:    String (integer counter, INCR)
TTL:     1 second (sliding window, refreshed each second)
Note:    Max 10 increments per second. 429 returned if exceeded.
Example: ratelimit:orders:a1b2c3d4-0001-4000-8000-000000000001
```

### Daily Loss Tracking
```
Key:     daily:pnl:{user_id}:{date}
Type:    String (INCRBYFLOAT, negative for losses)
TTL:     86400 seconds (expires at midnight IST next day)
Note:    Updated on every order fill. Read by RMS max_daily_loss check.
Example: daily:pnl:a1b2c3d4-0001-4000-8000-000000000001:2026-05-24
```

### Live Tick Pub/Sub (KiteTicker → Frontend WebSocket)
```
Channel: ticks:{user_id}
Message: JSON array of tick objects
         [{"token": 408065, "ltp": 1845.50, "bid": 1845.40, "ask": 1845.60,
           "volume": 1234567, "oi": 0, "timestamp": "2026-05-24T09:16:00+05:30"}]
Note:    Published by kite_ws.py on_ticks callback.
         Subscribed by WebSocket /ws/trades handler per connected user.
         One channel per user — multiplexes all subscribed instrument tokens.
```

### Order Update Pub/Sub (Kite postback → Frontend)
```
Channel: order_updates:{user_id}
Message: JSON order update object
         {"order_id": "...", "kite_order_id": "...", "status": "complete",
          "filled_qty": 50, "average_price": 1845.50, "exchange_time": "..."}
Note:    Published on order placement (trading engine) and KiteTicker
         on_order_update callback. Frontend WebSocket relays to client.
```

### Kite Instrument Token Cache
```
Key:     kite:token:{exchange}:{symbol}
Type:    String (integer instrument token)
TTL:     86400 seconds (refreshed daily at 8 AM IST)
Note:    Maps exchange+symbol → Kite instrument token for tick subscription.
Example: kite:token:NSE:INFY  →  408065
```

### Kite Session Pool Heartbeat
```
Key:     kite:session:active:{broker_account_id}
Type:    String ("1")
TTL:     600 seconds (10 minutes; refreshed on API call success)
Note:    Absence indicates the in-memory KiteConnect pool entry should be
         reloaded from broker_sessions table on next request.
Example: kite:session:active:ba001234-0000-4000-8000-000000000001
```
