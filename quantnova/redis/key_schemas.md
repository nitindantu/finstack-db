# QuantNova Redis Key Schema Reference

## Overview

Redis keys in the `quantnova` domain cover:
- Order state and execution cache
- Position cache (real-time P&L)
- Alpha signal cache
- Strategy performance snapshots
- Risk limit enforcement

All keys follow: `{namespace}:{entity_type}:{identifier}`

---

## 1. Order Cache

### Active Order State
```
Key:     order:state:{order_id}
Type:    Hash
Fields:
  order_id        — UUID
  user_id         — UUID
  symbol_id       — UUID
  side            — buy | sell
  order_type      — market | limit | stop | stop_limit
  quantity        — decimal
  filled_qty      — decimal
  price           — decimal (limit price)
  status          — pending | open | partial | filled | cancelled | rejected
  broker          — broker code string
  placed_at       — ISO timestamp
  updated_at      — ISO timestamp
TTL:     3600 seconds (1 hour after last update; refreshed on status change)
Example: order:state:ord00001-0000-4000-8000-000000000001
```

### User Pending Orders Set
```
Key:     order:pending:{user_id}
Type:    Set
Members: order_id strings
TTL:     None (managed explicitly; cleared on fill/cancel)
Example: order:pending:a1b2c3d4-0001-4000-8000-000000000001
```

### Order Rate Limiter (prevent order flooding)
```
Key:     order:ratelimit:{user_id}
Type:    Sorted Set
Score:   Timestamp (Unix ms)
Member:  order_id
TTL:     60 seconds (rolling window)
Example: order:ratelimit:a1b2c3d4-0001-4000-8000-000000000001
```

---

## 2. Position Cache

### Current Position per Symbol
```
Key:     position:{user_id}:{symbol_id}
Type:    Hash
Fields:
  quantity        — decimal (positive=long, negative=short)
  avg_cost        — decimal
  current_price   — decimal (latest LTP)
  unrealized_pnl  — decimal
  realized_pnl    — decimal
  last_updated    — ISO timestamp
TTL:     300 seconds (refreshed on price tick or order fill)
Example: position:a1b2c3d4-0001-4000-8000-000000000001:s0000000-0000-4000-8000-000000000001
```

### All Positions Summary (for dashboard)
```
Key:     positions:summary:{user_id}
Type:    String (JSON)
Value:   {"total_value": 1234567.00, "total_pnl": 45678.00, "positions": [...]}
TTL:     60 seconds
Example: positions:summary:a1b2c3d4-0001-4000-8000-000000000001
```

---

## 3. Signal Cache

### Latest Alpha Signal per Strategy
```
Key:     signal:latest:{strategy_id}:{symbol_id}
Type:    Hash
Fields:
  signal_type     — buy | sell | hold | exit
  strength        — float (0.0–1.0)
  confidence      — float (0.0–1.0)
  generated_at    — ISO timestamp
  model_version   — string
  metadata        — JSON string
TTL:     300 seconds (5 minutes; signals expire if model is stale)
Example: signal:latest:strat001-0000-4000-8000-000000000001:s0000000-0000-4000-8000-000000000001
```

### Active Signals Queue (per strategy for execution)
```
Key:     signal:queue:{strategy_id}
Type:    List
Members: JSON signal objects (pushed by signal generator, popped by executor)
TTL:     None (consumed as produced)
Example: signal:queue:strat001-0000-4000-8000-000000000001
```

---

## 4. Risk Limits Cache

### Current Risk Usage
```
Key:     risk:usage:{user_id}:{limit_type}
Type:    Hash
Fields:
  used            — current consumption value
  limit           — max allowed value
  breach          — "true" | "false"
  updated_at      — ISO timestamp
TTL:     60 seconds
Example: risk:usage:a1b2c3d4-0001-4000-8000-000000000001:max_order_value
```

---

## 5. Strategy Performance Snapshot

### Rolling P&L for Live Strategy
```
Key:     strategy:pnl:{strategy_id}:{date}
Type:    String (decimal)
TTL:     86400 seconds
Example: strategy:pnl:strat001-0000-4000-8000-000000000001:2026-05-17
```

---

## 6. Pub/Sub Channels

### Order Status Update
```
Channel: orders:{user_id}
Message: JSON {"order_id": "...", "status": "filled", "fill_price": 2960.00, "fill_qty": 50}
```

### Signal Generated
```
Channel: signals:{strategy_id}
Message: JSON {"symbol_id": "...", "signal_type": "buy", "strength": 0.87, "generated_at": "..."}
```

### Risk Breach Alert
```
Channel: risk:breach:{user_id}
Message: JSON {"limit_type": "max_drawdown", "used": 0.05, "limit": 0.03, "breached_at": "..."}
```
