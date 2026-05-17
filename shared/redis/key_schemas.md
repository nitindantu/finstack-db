# Shared Redis Key Schema Reference

## Overview

Redis keys in the `shared` domain cover cross-cutting concerns:
- User session management
- Rate limiting
- Feature flags

All keys follow: `{namespace}:{entity_type}:{identifier}`

---

## 1. Session Management

### User Session
```
Key:     session:{token_hash}
Type:    Hash
Fields:
  user_id      — UUID
  email        — User email
  plan_type    — free | basic | premium | enterprise
  roles        — JSON array of role names
  device_id    — Device fingerprint
  ip_address   — IPv4/IPv6
  created_at   — ISO timestamp
  expires_at   — ISO timestamp
TTL:     Sliding, max 86400 seconds (24h)
Example: session:8f14e45f-ceea-367f-a027-7a9b0b3a1c2d
```

### Active Sessions Per User (multi-device logout)
```
Key:     user:sessions:{user_id}
Type:    Set
Members: token_hash strings
TTL:     86400 seconds
Example: user:sessions:a1b2c3d4-0001-4000-8000-000000000001
```

---

## 2. Rate Limiting

### Sliding Window Rate Limiter
```
Key:     ratelimit:{user_id}:{endpoint}
Type:    Sorted Set
Score:   Timestamp (Unix ms)
Member:  Unique request ID (UUID)
TTL:     Window size in seconds
Example: ratelimit:a1b2c3d4-0001-4000-8000-000000000001:screener/execute
```

### API Key Rate Limiter
```
Key:     ratelimit:apikey:{key_hash}:{window}
Type:    String (counter)
TTL:     Window duration (seconds)
Example: ratelimit:apikey:abc123:60
```

### IP-Based Rate Limiter
```
Key:     ratelimit:ip:{ip_address}:{endpoint}
Type:    String (INCR counter)
TTL:     60 seconds
Example: ratelimit:ip:203.0.113.42:auth/login
```

---

## 3. Feature Flags

```
Key:     feature:{tenant_id}:{feature_name}
Type:    String
Value:   "on" | "off" | JSON config
TTL:     None (admin-managed)
Example: feature:f0000000-0000-4000-8000-000000000001:ai_recommendations
```

---

## 4. Notification State

### Unread Count Cache
```
Key:     notifications:unread:{user_id}
Type:    String (integer counter)
TTL:     3600 seconds
Example: notifications:unread:a1b2c3d4-0001-4000-8000-000000000001
```

### Pub/Sub: Alert Fired
```
Channel: alerts:{user_id}
Message: JSON {"alert_id": "...", "symbol_id": "...", "message": "...", "triggered_at": "..."}
```

### Pub/Sub: Order Status
```
Channel: orders:{user_id}
Message: JSON {"order_id": "...", "status": "filled", "fill_price": 2960.00, "fill_qty": 50}
```
