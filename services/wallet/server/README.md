# wallet_server

> The double-entry ledger. Every dollar that moves on Sorvete leaves a balanced pair of postings here. Source of truth for "do the books balance?".

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (schema) · **Wave active**: 3 · **Database**: `wallet` (Postgres)

## What this service owns

- **Wallet** — a single-currency balance for a User in a specific role (Customer / Merchant / Driver). A User can have multiple Wallets.
- **LedgerEntry** — immutable debit-or-credit posting, always created as a balanced pair within a `LedgerTransaction`
- **LedgerTransaction** — a set of postings that sum to zero across the system (double-entry guarantee)
- **CashFloat** — a Driver's current cash balance (Wave 3)

Wallet entries are **append-only**. There is no `UPDATE` — corrections are reversing entries.

## Responsibilities

- Open Wallets for new Customers / Merchants / Drivers in their default currency
- Post LedgerTransactions atomically (all entries succeed or all roll back)
- Refuse postings that would drive a Wallet negative beyond its allowed overdraft
- Compute balances on demand (sum of entries) and cache them via a materialized view
- Emit ledger events for `audit` and downstream analytics

## Out of scope

- **Payment capture (vendor side)** → owned by `payments`
- **Payout transfer execution** → owned by `payouts`
- **Loyalty points** → owned by `loyalty` (separate ledger)
- **Currency conversion** → cross-currency `Money` operations are a compile-time error

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `wallet.open(userId, role, currency)` | Idempotent — returns existing or new |
| `wallet.get(walletId)` | Balance + currency |
| `wallet.list(userId)` | All Wallets for a User |
| `transaction.post(entries, idempotencyKey)` | Atomic balanced posting (debit + credit) |
| `transaction.lookup(txnId)` | Replay |
| `entry.list(walletId, range)` | Statement |
| `cashFloat.get(driverId)` · `cashFloat.adjust(...)` | Wave 3 — Driver cash balance |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits**:

- `WalletOpened`
- `LedgerTransactionPosted`
- `WalletBalanceChanged`
- `CashFloatChanged`, `CashFloatRemitted` (Wave 3)

**Consumes**:

- `payments.PaymentCaptured` → post Customer-paid ↔ Merchant-receivable entries
- `payments.RefundIssued` → reverse
- `payouts.PayoutCompleted` → debit Merchant Wallet
- `gift_cards.GiftCardIssued` / `Redeemed` → ledger entries on the gift-card Wallet

## Cross-service calls

- **Synchronous**: none (Wallet is asked, never asks)
- **Asynchronous**: emits to `audit` (every txn), `analytics`, `risk`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 2), §11 (Wave 3)
- `CONTEXT.md` — _Wallet, LedgerEntry, Cash Float, Remittance, Settlement_
