# Cash-economy support from day 1 (Payment Method Adapter + Wallet ledger + OTP-on-delivery)

## Context

Sorvete must serve both card-economy markets (US, EU, etc.) and cash-economy markets (Somalia, Lebanon, Iraq, Egypt, Pakistan, Kenya, Nigeria, Bangladesh, …) from the launch entity. A card-only assumption excludes a large share of target markets; it would also bake Stripe-shaped state machines into `ordering`, `payments`, and `fulfillment` that do not fit cash or mobile-money flows.

Syria specifically is excluded — Stripe forbids it, Twilio SMS to Syria is OFAC-restricted, and Sumsub coverage is impractical. Re-entering Syria would require a separate legal entity and a parallel deployment, which is a future decision, not this one.

## Decision

1. **`payments` is built around a Payment Method Adapter pattern.** All adapters implement a uniform `(initiate, confirm, refund, reconcile)` interface. Launch adapters: `card_stripe`, `wallet_balance`, `cash_at_pickup`, `cash_on_delivery`, `mobile_money_evc` (EVC Plus / Hormuud), `mobile_money_zaad` (Zaad / Telesom), `mobile_money_mpesa` (M-Pesa, expansion-ready), `bank_transfer_local`. New countries arrive as configuration plus, where needed, new adapters.

2. **`wallet` is its own service** (added to the service catalog — see ADR-0003) implementing a double-entry ledger. Customer, Merchant, and Driver wallets all live here. All movements are immutable `LedgerEntry` pairs inside a `LedgerTransaction`. `gift_cards` and stored-value balances are implemented on top of `wallet`.

3. **OTP-on-delivery is mandatory** for `cash_on_delivery`. The Customer receives a numeric Order Completion Code at order placement; the Customer reads it to the Driver on handover; the Driver enters it; without a match, the Order does not close and `risk` is engaged.

4. **Driver cash custody** is modeled via a per-Driver `cash_float`, capped by `cash_float_cap` (configurable per market and per Driver tier). Cash exceeding the cap triggers scheduled or threshold-driven Remittance. Variance between expected and actual Remittance routes to `risk`.

5. **Platform Cut on cash orders accrues as a Merchant receivable.** It is discharged via periodic Settlement (cash drop, bank transfer, mobile-money debit, or netting against incoming Payouts). For card and mobile-money sales the Platform Cut is collected automatically before Payout.

6. **`kyc` is provider-pluggable per market.** Sumsub for global default, Smile ID for African markets, and a `kyc_manual` queue for low-document markets. The provider is selected by Merchant or Customer market, not hard-coded.

7. **Sanctioned markets are out-of-scope for the launch entity.** Syria is the named example. Re-entry requires a separate legal entity and a parallel stack instance, treated as a future decision.

8. **All money values carry currency.** No implicit USD anywhere. `pricing`, `payments`, `wallet`, `payouts`, and `analytics` operate per-currency. FX is explicit, dated, and recorded as its own LedgerEntry when conversion occurs.

9. **Notifications include WhatsApp** alongside SMS/Email/Push/WebPush. In cash-economy markets WhatsApp is often the dominant comms channel; the `notifications` service treats it as a peer transport.

## Why

Cash flows have a fundamentally different state machine, trust model, and reconciliation surface from card flows. Folding them into a card-shaped Payments service would either produce a Stripe-flavored model that misrepresents how cash works, or accumulate enough special cases to make the service unmaintainable. The Adapter pattern keeps the Order/Payment/Refund contract uniform while letting each method implement its own messy reality. The Wallet service exists because balances are a different consistency model (immutable ledger) than payment intents (mutable state machine) — and because Drivers and Merchants have balances too, not just Customers.

OTP-on-delivery substitutes for the chargeback mechanism that card networks provide for free. Without it, cash markets have no anti-fraud loop on the delivery handoff.

## Consequences

- `payments` cannot be coupled to Stripe-specific concepts at its interface layer — Stripe is *one adapter*.
- `wallet` is the system of record for balances; no other service reconstructs balances from events.
- Onboarding a new market is a configuration task (currency, KYC provider, payment methods enabled, language, RTL) — not a code change in `ordering` or `payments`.
- The `risk` service consumes events from `payments`, `wallet`, `fulfillment` (remittance variance), and `ordering` (OTP failures) and produces holds/freezes that any of those services consult.
- Sanctions screening runs at Merchant onboarding (in `kyc`) and on Customer KYC checkpoints (in `kyc`), gating downstream service access via `identity` claims.

## Status

accepted
