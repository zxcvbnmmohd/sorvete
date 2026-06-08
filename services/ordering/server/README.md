# ordering_server

> The conductor. Owns Cart → Order → state machine. Every other service in the commerce path either feeds it or reacts to it.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 · **Database**: `ordering` (Postgres)

## What this service owns

- **Cart** — Customer's in-progress selection, scoped to one Merchant (a Customer can have many concurrent Carts, one per Merchant)
- **Order** — committed Cart with a lifecycle state machine
- **OrderLine** — `(variantId, qty, modifiers, lineState)` — the unit the kitchen prepares
- **Order state machine** — `PLACED → PAID → ACCEPTED → PREPARING → READY → COMPLETED` (plus `CANCELLED`, `REFUNDED`)

`ordering` is **client-authoritative for write-time** (POS can past-date when offline) but the canonical state always lives here.

## Responsibilities

- Create / modify / submit Carts
- Transition Orders through the lifecycle (conditional on Product `requires_preparation` and Location `fulfillment_profile`)
- Coordinate with `pricing`, `payments`, `inventory`, `kitchen` synchronously when needed
- Emit every state transition to NATS so the ripple effect (notifications, kitchen ticket, inventory decrement, audit, analytics) happens automatically
- Reconcile offline-queued orders with server-authoritative state on POS re-sync

## Out of scope

- **Price math** → owned by `pricing`
- **Money capture** → owned by `payments`
- **Stock decrement** → owned by `inventory` (reacts to `OrderPlaced`)
- **KDS ticket lifecycle** → owned by `kitchen` (reacts to `OrderPlaced`)
- **Driver dispatch** → owned by `fulfillment` (reacts to `OrderReady` for delivery orders)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `cart.create(customerId, merchantId, locationId, idempotencyKey)` | New Cart |
| `cart.addLine(cartId, variantId, qty, modifiers, idempotencyKey)` | Add a line |
| `cart.removeLine(cartId, lineId, idempotencyKey)` | Remove |
| `cart.get(cartId)` | Current state |
| `order.checkout(cartId, paymentMethod, idempotencyKey)` | Cart → Order, kicks off `payments` |
| `order.accept(orderId, deviceToken, idempotencyKey)` | POS accepts |
| `order.markPreparing(orderId, idempotencyKey)` | Kitchen started |
| `order.markReady(orderId, idempotencyKey)` | Ready for pickup / handoff |
| `order.complete(orderId, idempotencyKey)` | Final state |
| `order.cancel(orderId, reason, idempotencyKey)` | Cancel (refund if paid) |
| `order.get(orderId)` | Read |
| `order.listFor(customerId | merchantId | locationId)` | Various scopes |

All mutating endpoints require an `idempotencyKey` and accept past-dated timestamps (offline POS replay).

## Domain events

**Emits** (NATS subject `outbox.ordering.*`):

- `CartCreated`, `CartLineAdded`, `CartLineRemoved`
- `OrderPlaced`, `OrderAccepted`, `OrderPreparing`, `OrderReady`, `OrderCompleted`
- `OrderCancelled`, `OrderRefunded`

**Consumes**:

- `payments.PaymentCaptured` → transition Order to ACCEPTED
- `payments.PaymentFailed` → transition Order to FAILED
- `payments.RefundIssued` → transition Order to REFUNDED
- `inventory.OversellConflictRaised` → surface conflict to POS

## Cross-service calls

- **Synchronous**: `pricing` (quote), `payments` (createIntent), `device` (validate device token), `merchant` (verify Location)
- **Asynchronous**: emits the central event firehose — consumed by `inventory`, `kitchen`, `fulfillment`, `notifications`, `audit`, `analytics`, `loyalty`, `promotions`, `recommendations`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §6 (happy path), §7 (outbox), §8 (offline POS)
- `CONTEXT.md` — _Cart, Order, OrderLine, lifecycle states_
