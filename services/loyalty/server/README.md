# loyalty_server

> The punch card. Tracks Customer points, tiers, and rewards. Earned on orders; burned on rewards.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `loyalty` (Postgres)

## What this service owns

- **LoyaltyAccount** — `(customerId, merchantId, pointsBalance, tier)`
- **PointsLedger** — append-only earn / burn / expire entries
- **Tier** — Merchant-defined thresholds and benefits
- **Reward** — what a Customer can redeem points for

Loyalty is Merchant-scoped (different Merchants can run different programs), but the underlying Customer is platform-scoped.

## Responsibilities

- Award points on `OrderCompleted` per Merchant's earning rules
- Maintain tier transitions (PointsAwarded → tier recalc → emit `TierUpgraded`)
- Redeem points for rewards (which become discounts via `promotions` or wallet credit via `wallet`)
- Expire points per Merchant policy

## Out of scope

- **Discount math at checkout** → owned by `pricing` (which consumes redemption tokens from this service)
- **Gift cards** → owned by `gift_cards`
- **Punch-card-as-marketing-campaign** → owned by `marketing`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `account.get(customerId, merchantId)` | Current points + tier |
| `points.award(customerId, merchantId, amount, reason, idempotencyKey)` | Earn |
| `points.redeem(customerId, merchantId, rewardId, idempotencyKey)` | Burn for a reward |
| `points.expire(customerId, merchantId)` | Run expiration policy |
| `tier.list(merchantId)` | Merchant's tier ladder |
| `reward.list(merchantId)` | Available rewards |

## Domain events

**Emits**:

- `PointsAwarded`, `PointsRedeemed`, `PointsExpired`
- `TierUpgraded`, `TierDowngraded`

**Consumes**:

- `ordering.OrderCompleted` — award points
- `ordering.OrderRefunded` — reverse earned points

## Cross-service calls

- **Synchronous**: `merchant` (verify program exists), `pricing` (when reward is a discount), `wallet` (when reward is credit)
- **Asynchronous**: emits to `audit`, `analytics`, `notifications`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1), §11 (Wave 4)
