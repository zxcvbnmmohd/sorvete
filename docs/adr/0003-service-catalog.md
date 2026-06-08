# Service catalog — 33 services across 5 tiers, `tax` as a shared library

## Context

ADR-0001 commits to microservices and ADR-0002 to database-per-service. The remaining decomposition question was: which bounded contexts deserve a dedicated service, and which fold into another. Six fold-in candidates were debated (`kyc`, `tax`, `disputes`, `gift_cards`, `marketing`+`notifications`, `recommendations`). Five were kept separate; one (`tax`) was demoted to a shared library. One service not in the original list (`wallet`) was added when cash-economy support was scoped (see ADR-0004).

## Decision

**33 services + 1 shared library.**

### Tier 0 — Foundation (6)
`identity`, `merchant`, `device`, `media`, `geo`, `config`

### Tier 1 — Commerce core (7)
`catalog`, `inventory`, `pricing`, `promotions`, `loyalty`, `gift_cards`, `ordering`

### Tier 2 — Money & risk (7)
`payments`, `payouts`, `wallet`, `disputes`, `risk`, `kyc`  · plus shared library `packages/tax`

### Tier 3 — Fulfillment (3)
`kitchen`, `fulfillment`, `reservations`

### Tier 4 — Engagement, discovery, growth (6)
`search`, `recommendations`, `reviews`, `ads`, `marketing`, `notifications`

### Tier 5 — Platform & ops (4)
`webhooks`, `analytics`, `audit`, `support`

### Notable inter-service relationships

- **`tax`** is a Dart library at `packages/tax`, consumed by `pricing`. A pure `(jurisdiction, line_items) → tax_amount` function; promoted to a service only if it ever owns stateful filing/return data.
- **`gift_cards`** is implemented on top of `wallet` — a gift card balance is a Wallet account with a restricted top-up source. The `gift_cards` service owns codes, redemption rules, and presentation.
- **`kyc`** is provider-pluggable per market via a Strategy pattern: `kyc_sumsub` (default global), `kyc_smile` (African markets), `kyc_manual` (low-document fallback).
- **`geo`** is a service (not a library) because it owns Merchant-defined delivery-zone polygons (PostGIS), shared rate-limit budgets for Nominatim/OpenRouteService self-hosted endpoints, and a cross-service address-validation cache.
- **`config`** is built in-house (no Unleash/Flagsmith dependency).
- **`recommendations`** owns its own feedback-loop state (impressions, clicks, conversions, dismissals) — it is not a read-only projection of `analytics`.

## Why

Each service's existence is justified on at least one of:
- **Data-ownership boundary** — single source of truth for an aggregate root
- **Compliance scope** — PCI, SOC2, KYC retention, biometric-data law
- **Distinct scaling profile** — read-heavy vs. write-heavy, OLAP vs. OLTP, push-pull vs. event-driven
- **Distinct consistency model** — double-entry ledger vs. CRUD vs. event stream
- **Third-party-vendor isolation** — wraps a vendor that has its own SLA, rate limits, and rotation cadence

Where none of those held, the candidate was folded. `tax` failed all five at launch scope, so it lives as a library.

## Considered alternatives

- **Cart as its own service** — rejected. Cart→Order is the most coupled transition in the system; splitting adds a saga for no real benefit.
- **Staff/team as its own service** — rejected. Staff is owned by `merchant` as Merchant-scoped User memberships.
- **Tax as a service** — rejected for launch. Re-evaluate when the platform owns filing/reporting data.
- **`marketing` + `notifications` merged** — rejected. Different SLAs (transactional vs. bulk), consent models, and rate budgets. They share adapters (Twilio, FCM, Postal, WhatsApp), not state.

## Consequences

- `pubspec.yaml` workspace list expands to include `services/*` (33 Serverpod projects contributing ~100 packages between them) plus `packages/tax`.
- `docker-compose.yml` grows to ~70 long-running containers at parity: 33 services + 33 Postgres + supporting infra (NATS JetStream, Meilisearch, MinIO, Valkey, Postal, Nominatim, OpenRouteService/Valhalla, ClickHouse, Grafana/Loki/Prometheus/Tempo, GlitchTip, Infisical).
- Cross-service data flow defaults to event-driven local-projection reads, not synchronous joins.

## Status

accepted
