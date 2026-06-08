# gift_cards_server

> Gift card codes + redemption. Built on top of `wallet` — a gift card balance is a Wallet account with a restricted top-up source.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `gift_cards` (Postgres)

## What this service owns

- **GiftCard** — `(code, issuedFrom, faceValue, status, walletAccountId)`
- **Redemption** — record of "code X applied to Order Y"
- **IssuancePolicy** — Merchant rules for how codes are generated (length, prefix, expiry)

The actual balance lives in a dedicated `wallet` account. This service owns the *code* and the *rules*; `wallet` owns the *money*.

## Responsibilities

- Generate gift card codes (cryptographically random, collision-checked)
- Process purchase: charge buyer via `payments`, post `wallet` credit
- Process redemption: validate code + apply discount via `promotions` *or* debit `wallet` for cash equivalent
- Enforce expiry, fraud limits, and (where legally required) escheatment

## Out of scope

- **The money** → owned by `wallet`
- **Customer-to-Customer money transfer** → not a v1 feature
- **Loyalty rewards** → owned by `loyalty` (separate program)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `giftCard.issue(merchantId, faceValue, paymentIntentId, idempotencyKey)` | Buy a gift card |
| `giftCard.lookup(code)` | Inspect a code (balance, status) |
| `giftCard.redeem(code, orderId, amount, idempotencyKey)` | Apply to an Order |
| `giftCard.deactivate(code, reason)` | Admin / fraud handling |

## Domain events

**Emits**:

- `GiftCardIssued`, `GiftCardRedeemed`, `GiftCardDeactivated`, `GiftCardExpired`

**Consumes**:

- `payments.PaymentCaptured` (when capture is for a gift-card purchase) — issue the card

## Cross-service calls

- **Synchronous**: `payments` (charge buyer), `wallet` (open + credit + debit account), `promotions` (when applied as discount)
- **Asynchronous**: emits to `audit`, `notifications` (deliver code to recipient)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1), §11 (Wave 4)
- `docs/adr/0003-service-catalog.md` — "gift_cards is implemented on top of wallet"
