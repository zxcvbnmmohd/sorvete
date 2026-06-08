# pricing_server

> The cashier's calculator. Given a Cart, returns the final money quote: subtotal + tax + fees + surge − promo. Stateless math; doesn't store prices.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 · **Database**: `pricing` (Postgres — only for surge rules & fee tables, not per-quote storage)

## What this service owns

- **FeeRule** — Merchant-configurable convenience / service fees
- **SurgeRule** — time/location-based surge multipliers (Wave 2+)
- **QuoteLog** — append-only record of quotes (for audit + dispute reconstruction)

Per-Variant list prices live in `catalog`. Tax math lives in the `packages/tax` shared library.

## Responsibilities

- Accept a cart snapshot, return a `Quote { subtotal, tax, fees, surge, discounts, total }` — all in typed `Money`
- Call `packages/tax.taxOnQuote(jurisdiction, lines)` for tax math
- Call `promotions.evaluate(cart)` for promo / coupon discounts
- Apply Merchant & platform surge / fee rules
- Be **deterministic**: same cart snapshot in → same Quote out

## Out of scope

- **List prices** → owned by `catalog` (on the Variant)
- **Tax filing / returns** → not in v1 (tax is a pure library for now)
- **Currency conversion** → cross-currency operations are a compile-time error; one Merchant = one currency
- **Final charge** → owned by `payments` (pricing only *quotes*)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `quote.forCart(cartSnapshot, idempotencyKey)` | Returns Quote |
| `quote.preview(cartSnapshot)` | Same as `forCart` but logged-only (no idempotency record) |
| `feeRule.upsert(merchantId, ...)` | Merchant-side fee config |
| `surgeRule.upsert(merchantId, locationId, ...)` | Wave 2+ surge config |
| `quote.lookup(quoteId)` | Replay a stored quote |

## Domain events

**Emits** (NATS subject `outbox.pricing.*`):

- `FeeRuleChanged`, `SurgeRuleChanged`
- `QuoteGenerated` — sampled, used by `analytics`

**Consumes**:

- `catalog.VariantUpdated` — invalidate any short-lived in-memory quote caches

## Cross-service calls

- **Synchronous**: `promotions` (evaluate discounts), `catalog` (lookup list prices on cart lines)
- **Asynchronous**: emits to `audit`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1), §6 step 5
- `packages/tax` (the shared library this service consumes)
