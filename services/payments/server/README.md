# payments_server

> The cash drawer + card reader + mobile-money client. Uniform Payment Method Adapter — one interface, many backends (Stripe, cash, EVC Plus, M-Pesa, …).

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (Stripe test mode) · **Database**: `payments` (Postgres)

## What this service owns

- **PaymentIntent** — platform-side envelope for a planned payment (state machine varies by method)
- **PaymentMethod adapters** — `card_stripe`, `wallet_balance`, `cash_at_pickup`, `cash_on_delivery`, `mobile_money_evc`, `mobile_money_zaad`, `mobile_money_mpesa`, `bank_transfer_local`
- **Reconciliation records** — adapter-specific reconciliation state

Each adapter implements `initiate · confirm · refund · reconcile`. Adding a new method = one adapter, not a service rewrite.

## Responsibilities

- Create a PaymentIntent for an Order using the requested method
- Drive the method-specific state machine (Stripe webhook, cash collection record, mobile-money callback)
- Issue refunds (full or partial)
- Reconcile against vendor records (Stripe payouts, EVC statements, etc.)
- Emit unambiguous outcomes (`PaymentCaptured` / `PaymentFailed` / `RefundIssued`) so `ordering` can transition

## Out of scope

- **Merchant payouts (platform → Merchant bank)** → owned by `payouts`
- **Wallet ledger entries** → owned by `wallet` (which `payments` calls)
- **Fraud scoring** → owned by `risk` (which `payments` consults)
- **Disputes / chargebacks** → owned by `disputes`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `intent.create(orderId, method, idempotencyKey)` | Create intent + invoke adapter |
| `intent.confirm(intentId, adapterPayload, idempotencyKey)` | For methods that need client confirmation |
| `intent.cancel(intentId)` | Pre-capture cancel |
| `refund.issue(captureId, amount, reason, idempotencyKey)` | Full or partial refund |
| `intent.get(intentId)` | State + adapter payload |
| `webhooks.stripe(payload, signature)` | Stripe inbound webhooks |
| `webhooks.evc(payload)` | EVC Plus inbound callback |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits**:

- `PaymentIntentCreated`
- `PaymentCaptured`, `PaymentFailed`, `PaymentCancelled`
- `RefundIssued`, `RefundFailed`
- `ReconciliationCompleted`, `ReconciliationDiscrepancy`

**Consumes**:

- `ordering.OrderCancelled` — cancel any open intent
- `risk.RiskHoldPlaced` — block capture

## Cross-service calls

- **Synchronous**: `risk` (pre-capture screen), `wallet` (for `wallet_balance` method), `merchant` (Stripe Connect account lookup)
- **Asynchronous**: emits to `ordering`, `wallet`, `audit`, `analytics`, `notifications`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

**Local env**: requires `STRIPE_SECRET_KEY` (test mode) in `config/passwords.yaml`. Mobile-money adapters use stubs locally.

## References

- `ARCHITECTURE.md` §9 (Adapter pattern), §4 (Tier 2)
- `docs/adr/0004-cash-economy-from-day-one.md`
- `CONTEXT.md` — _Payment Method, Payment Intent_
