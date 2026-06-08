# payouts_server

> The Friday paycheck. Computes what each Merchant is owed, schedules transfers, and ships statements.

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (stub) · **Wave deep**: 5 · **Database**: `payouts` (Postgres)

## What this service owns

- **PayoutSchedule** — Merchant payout cadence (daily / weekly / on-demand)
- **PayoutBatch** — a scheduled or ad-hoc payout cycle
- **Statement** — itemized record of what's in a payout (gross sales, platform cut, fees, refunds, settlement netting)
- **BankAccount** — Merchant's payout destination (Stripe Connect external account, or local bank for non-Stripe markets)

## Responsibilities

- Aggregate completed PaymentIntents into a PayoutBatch on the Merchant's schedule
- Subtract platform cut, processing fees, refunds, and any outstanding Settlement (cash collected by Merchant on behalf of platform)
- Initiate the actual transfer (Stripe Connect transfer, or local bank file in cash markets)
- Generate the Statement PDF and notify the Merchant
- Reconcile vendor confirmations and emit `PayoutCompleted` / `PayoutFailed`

## Out of scope

- **Charging the customer** → owned by `payments` (this is the reverse direction)
- **Double-entry ledger** → owned by `wallet`
- **KYC required to enable payouts** → owned by `kyc` (this service blocks payouts until KYC status is `verified`)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `schedule.set(merchantId, cadence)` | Daily / weekly |
| `schedule.get(merchantId)` | Current cadence |
| `bankAccount.attach(merchantId, accountPayload)` | Add destination |
| `batch.preview(merchantId, asOfDate)` | What would the next payout look like? |
| `batch.run(merchantId, idempotencyKey)` | Force an out-of-cycle payout |
| `statement.get(payoutId)` | Detailed statement |
| `statement.list(merchantId, range)` | History |

## Domain events

**Emits**:

- `PayoutScheduled`, `PayoutInitiated`, `PayoutCompleted`, `PayoutFailed`
- `StatementGenerated`

**Consumes**:

- `payments.PaymentCaptured` → add to next batch
- `payments.RefundIssued` → deduct from next batch
- `wallet.SettlementRemitted` → net against outstanding Settlement
- `kyc.KycApproved` / `KycRejected` → unblock / block payouts

## Cross-service calls

- **Synchronous**: `kyc` (verify status), `merchant` (Stripe Connect account), `wallet` (post double-entry)
- **Asynchronous**: emits to `audit`, `notifications`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 2), §11 (Wave 5)
- `CONTEXT.md` — _Payout, Settlement, Platform Cut_
