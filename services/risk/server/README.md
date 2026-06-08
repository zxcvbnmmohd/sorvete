# risk_server

> The fraud detector. Computes risk scores, runs velocity rules, places holds when something looks off.

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (basic) · **Wave deep**: 5 (ML signals) · **Database**: `risk` (Postgres)

## What this service owns

- **RiskAssessment** — score + reasons for an Order or PaymentIntent
- **RiskRule** — declarative velocity / fingerprint / amount rules
- **Hold** — `(targetType: order | payout | wallet, targetId, reason, expiresAt)`
- **Signal** — historical features per (Customer, Merchant, Device, IP, Card BIN) used as inputs

## Responsibilities

- Pre-capture: score a PaymentIntent synchronously (called by `payments`); allow / hold / decline
- Post-event: ingest every interesting event (logins, failed payments, disputes, refunds, cash variances) as a signal
- Place / release holds on Orders, Payouts, or Wallets
- Surface the explanation to `support` and the Admin app
- (Wave 5) Run ML scoring models alongside rule-based scoring

## Out of scope

- **Identity verification** → owned by `kyc`
- **Chargeback handling** → owned by `disputes`
- **Authorization (allowed to do X?)** → owned by `identity` + `merchant` (RBAC)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `assess.paymentIntent(intentId)` | Synchronous score for `payments` |
| `assess.order(orderId)` | Score an Order at any state |
| `hold.place(targetType, targetId, reason, ttl, idempotencyKey)` | Block a downstream action |
| `hold.release(holdId, reason, idempotencyKey)` | Lift a hold |
| `hold.list(filter)` | Admin view |
| `rule.upsert(...)` | Manage declarative rules |
| `signal.recent(entityType, entityId)` | Recent signals (debug / dispute support) |

## Domain events

**Emits**:

- `RiskAssessed`
- `RiskHoldPlaced`, `RiskHoldReleased`, `RiskHoldExpired`

**Consumes**:

- `identity.UserSignInFailed` (velocity), `payments.PaymentFailed`, `payments.PaymentCaptured`, `disputes.DisputeOpened`, `ordering.OrderCancelled`, `wallet.CashFloatRemitted` (variance) — all become signals

## Cross-service calls

- **Synchronous**: called by `payments`, `payouts`, `ordering` (each before doing the thing)
- **Asynchronous**: emits to `audit`, `support`, `notifications`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 2), §11 (Wave 5)
