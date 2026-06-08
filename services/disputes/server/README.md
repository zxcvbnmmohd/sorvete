# disputes_server

> The complaint desk. Handles chargebacks from Stripe, refund disputes, and "I never got my order" claims.

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (stub) · **Wave deep**: 5 · **Database**: `disputes` (Postgres)

## What this service owns

- **Dispute** — a contested charge with state machine (`opened → needs_evidence → submitted → won | lost`)
- **Evidence** — Merchant-uploaded documents and structured fields (receipt, shipping proof, communication)
- **DisputeOutcome** — won / lost / accepted, plus financial impact

## Responsibilities

- Receive chargeback webhooks from Stripe (and equivalents from mobile-money providers later)
- Open a Dispute, notify the Merchant, demand evidence by the provider's deadline
- Submit Merchant evidence back to the provider
- Apply the financial outcome via `wallet` (debit Merchant Wallet on lost dispute)
- Escalate to `support` if the Merchant misses the response window

## Out of scope

- **Customer-initiated refunds (not contested)** → handled by `payments` directly
- **Order cancellations** → owned by `ordering`
- **Risk scoring** → owned by `risk` (which may flag fraud before a charge becomes a dispute)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `dispute.open(paymentIntentId, reason, providerRef, idempotencyKey)` | Open from webhook |
| `dispute.list(merchantId, status?)` | Merchant inbox |
| `dispute.get(disputeId)` | Detail + evidence checklist |
| `evidence.upload(disputeId, fieldKey, mediaId)` | Attach |
| `evidence.submit(disputeId, idempotencyKey)` | Finalize and send |
| `dispute.recordOutcome(disputeId, outcome, idempotencyKey)` | Provider-side outcome ingest |
| `webhooks.stripe(payload, signature)` | Dispute webhooks (separate from `payments`' webhooks) |

## Domain events

**Emits**:

- `DisputeOpened`, `DisputeEvidenceSubmitted`, `DisputeWon`, `DisputeLost`, `DisputeExpired`

**Consumes**:

- `payments.PaymentCaptured` — index the charge for fast lookup when a dispute lands

## Cross-service calls

- **Synchronous**: `payments` (lookup capture), `wallet` (post chargeback debit on loss)
- **Asynchronous**: emits to `audit`, `notifications` (Merchant alert), `support` (auto-escalate), `risk`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 2), §11 (Wave 5)
