# Vertical-slice wave build methodology + TDD/E2E/SOLID/DRY/KISS mandate

## Context

ADR-0003 commits to 32 services + 1 shared library at production parity. The remaining question was *how* to build that — three methodologies were considered:

- **(a) Big bang**: build every service to parity in parallel; launch when everything is done.
- **(b) Depth-first**: one service finished before the next starts; ship in order of dependency tier.
- **(c) Vertical-slice waves**: every wave wires every service end-to-end at progressively deeper feature surface.

## Decision

**(c) Vertical-slice waves.** Build proceeds in 7 named waves (0–6). Wave 0 scaffolds every service with a minimum surface that supports a single end-to-end happy path; each subsequent wave deepens every service for new capabilities. Public launch is the end of Wave 6.

### Wave plan

| Wave | Theme | New capability landing this wave |
|---|---|---|
| **0** | Skeleton walking | All 32 Serverpod projects scaffolded; all 32 Postgres DBs; Docker Compose + Dokploy deploy; CI/CD; LGTM observability + GlitchTip; Infisical secrets; NATS JetStream; minimum E2E happy path (1 Merchant, 1 Location, 3 Products, Stripe payment, email receipt). |
| **1** | Restaurant vertical — US — dine-in & pickup | Variants, Modifiers, Inventory, KDS service + app, conditional prep state machine, Refunds, FCM/APNs push, Device pairing, POS app (online-only). One real restaurant in closed alpha. |
| **2** | Delivery + marketplace + multi-merchant | Fulfillment + Driver app, geo + delivery zones, multi-merchant browse, multiple concurrent Carts, Search (Meilisearch), Twilio SMS, dropoff privacy gate. |
| **3** | Cash economy + first emerging market | Wallet ledger live, Cash-on-Delivery + OTP, Cash-at-Pickup, EVC Plus mobile money, WhatsApp transport, Arabic + RTL, KYC (Sumsub + Smile + manual queue), Driver cash float + Remittance, Merchant Settlement. |
| **4** | Engagement & monetization | Promotions, Loyalty, Gift cards on Wallet, Ads (sponsored listings + auctions), Marketing (campaigns/segments/drips), Reviews, Reservations, Recommendations. |
| **5** | Compliance, payouts, ops at scale, offline POS | Disputes (full chargeback workflow), Payouts (scheduled, multi-method), Audit (immutable log + compliance exports), Risk (fraud models, velocity, ML scoring), Support tools, Webhooks for merchant integrations, full Analytics on ClickHouse, `packages/tax` multi-jurisdiction, **offline POS local-first store + sync engine**. |
| **6** | Parity launch + polish | Multi-market live (US + 1 EU + 2–3 cash markets), self-service POS mode, multi-location Merchants, performance + cost tuning, A/B infra, public launch. |

### Disciplines (mandatory, enforced from Wave 0)

- **TDD**: red → green → refactor for every service. CI policy: PRs must include failing-test commits before implementation commits. No merge if test diff does not grow proportional to code diff.
- **E2E**: every wave contains new cross-service E2E tests covering its new contracts. Wave 0's happy path itself is the first E2E pipeline, running on every PR against an ephemeral Docker Compose.
- **SOLID at the service boundary**: each service has a single bounded reason to change. Adapters (Payment Method, KYC Provider, Notification Transport) are DI-injected. No service depends on another service's internals — only its API contracts and events.
- **DRY via shared packages**: Money + Currency types, error envelopes, idempotency-key helpers, audit-emission helpers, ledger primitives live in `packages/*`. Domain logic does not.
- **KISS per wave scope**: no service or feature lands before the wave it belongs to. No premature splits, no premature optimization.

### Offline-POS architectural rules — enforced from Wave 0

The local-first store + sync engine code in the POS app lands in Wave 5, but the **API constraints required to make offline POS work** apply to every mutating endpoint shipped from Wave 0 onward:

- **Idempotent**: every mutating endpoint accepts a client-supplied idempotency key and de-duplicates server-side for a documented window.
- **Past-dated-timestamp tolerant**: an Order placed offline at 12:01 syncing at 12:47 is accepted with its original timestamp; lifecycle state transitions are computed from event-time, not wall-clock.
- **Conflict-aware**: writes that conflict with prior server-known state publish a conflict signal (not silently last-write-wins). Per-entity merge policy is defined per service.
- **Causally ordered**: depends-on relationships are explicit in the API. A payment capture cannot be processed for an order the cloud has not yet been told about.

Retrofitting these rules in Wave 5 would require rewriting roughly half the platform's mutating endpoints.

## Why

Integration risk is the leading failure mode of microservices projects. Vertical slicing surfaces every cross-service contract at Wave 0, when bugs are cheapest. Dogfooding starts at Wave 1 alpha (one real Merchant) rather than at year-3 of a dark pre-launch period. TDD + E2E land as enforced CI policy at Wave 0, before any temptation exists to "add tests later."

(a) was rejected because a 3–5 year dark period with no user feedback is a known capital-burn pattern.
(b) was rejected because nothing works end-to-end until late in the build, integration issues compound, and morale erodes.

## Consequences

- The pre-launch period is structured as 7 named waves with concrete, demoable deliverables at the end of each.
- Wave 1 closed alpha lands roughly 12–18 months from Wave 0 start. Public launch is at Wave 6.
- Each wave's E2E tests must pass before the next wave begins.
- Offline-POS API constraints are non-negotiable from Wave 0 — they shape every endpoint signature in every service.
- The wave structure is the load-bearing roadmap. Re-prioritization between waves is allowed; jumping a wave forward (e.g. building Loyalty before Cash) is not.

## Status

accepted
