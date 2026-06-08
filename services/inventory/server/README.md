# inventory_server

> The stockroom clerk. Counts what's on the shelf at each Location, and flips the "86" flag when it runs out.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 · **Database**: `inventory` (Postgres)

## What this service owns

- **StockLevel** — `(merchantId, locationId, variantId, qtyOnHand, qtyReserved, trackingMode)`
- **86 flag** — a manual "this Variant is unavailable right now" override (kitchen lingo: "86 the burrito")
- **StockAdjustment** — append-only log of every change (sale, restock, waste, count correction)

**Server-authoritative**. The offline POS holds a read-only mirror; mismatches surface as conflicts.

## Responsibilities

- Decrement stock on `OrderPlaced` (consumer)
- Increment stock on `OrderCancelled` / `OrderRefunded` (consumer)
- Accept manual adjustments from the Merchant app (restocks, waste, counts)
- Maintain the 86 flag and emit changes for `catalog` / clients to react
- Raise oversell-conflict events when an offline-queued Order would drive stock negative

## Out of scope

- **Product / Variant definitions** → owned by `catalog`
- **Pricing or cost-of-goods** → owned by `pricing`
- **Supplier / purchase orders** → not in v1
- **Multi-warehouse logistics** → each Location is its own bucket; cross-Location transfers come later

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `stock.get(merchantId, locationId, variantId)` | Current level |
| `stock.list(merchantId, locationId)` | All Variants at a Location |
| `stock.adjust(locationId, variantId, delta, reason, idempotencyKey)` | Manual adjustment |
| `stock.setTrackingMode(locationId, variantId, mode)` | `tracked` / `untracked` / `eighty_sixed` |
| `eightySix.set(locationId, variantId, isUnavailable)` | Flip 86 flag |

All mutating endpoints require an `idempotencyKey` and tolerate past-dated timestamps (offline POS replay).

## Domain events

**Emits** (NATS subject `outbox.inventory.*`):

- `StockAdjusted`, `StockLevelChanged`
- `ItemEightySixed`, `ItemEightySixCleared`
- `OversellConflictRaised`

**Consumes**:

- `ordering.OrderPlaced` — decrement
- `ordering.OrderCancelled`, `ordering.OrderRefunded` — increment
- `catalog.VariantArchived` — archive matching StockLevels

## Cross-service calls

- **Synchronous**: `catalog` (validate variantId)
- **Asynchronous**: emits to `audit`, `analytics`, `notifications` (low-stock alerts)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1), §8 (Offline POS — `inventory` is server-authoritative)
- `CONTEXT.md` — _Catalog vs. Inventory distinction_
