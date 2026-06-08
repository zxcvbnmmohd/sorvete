# promotions_server

> The coupon book. Coupons, deals, BOGO. Asked by `pricing` whether a discount applies to a Cart.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 (stub returns `[]`) · **Wave deep**: 4 · **Database**: `promotions` (Postgres)

## What this service owns

- **Promotion** — the rule: code-based / automatic, eligibility predicate, discount math
- **PromotionRedemption** — append-only log of "promo X applied to order Y" for accounting + caps
- **PromotionBudget** — total / per-Customer / per-day caps

## Responsibilities

- CRUD Promotions via the Merchant app (Wave 4)
- For each cart, evaluate eligibility and compute the discount — called synchronously by `pricing`
- Enforce caps and per-Customer redemption limits
- Emit redemption events for audit + analytics

In Wave 0, `evaluate` returns an empty discount array so `pricing` and `ordering` can be exercised end-to-end without promo logic.

## Out of scope

- **Loyalty points / tiered rewards** → owned by `loyalty`
- **Gift cards** → owned by `gift_cards`
- **Platform-wide marketing campaigns** → owned by `marketing` (which may *create* promos here)
- **Final price math** → owned by `pricing`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `promotion.create(merchantId, ...)` | Define a promo |
| `promotion.update(id, patch)` | Edit |
| `promotion.archive(id)` | Soft-delete |
| `promotion.list(merchantId)` | List active promos |
| `promotion.evaluate(cart)` | Internal: returns matched discounts (called by `pricing`) |
| `promotion.redeem(promoId, cartId, idempotencyKey)` | Record a successful application |

## Domain events

**Emits** (NATS subject `outbox.promotions.*`):

- `PromotionCreated`, `PromotionUpdated`, `PromotionArchived`
- `PromotionRedeemed`

**Consumes**:

- `ordering.OrderPlaced` — finalize redemption record
- `ordering.OrderCancelled`, `ordering.OrderRefunded` — reverse redemption

## Cross-service calls

- **Synchronous**: called by `pricing.quote.forCart`
- **Asynchronous**: emits to `audit`, `analytics`, `marketing`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1), §11 (Wave 4)
