# Sorvete — Architecture Overview

> Single-document recap of what we're building, the stack we're building it on, and how every piece is connected. This document synthesizes `CONTEXT.md`, all ADRs in `docs/adr/`, and the Wave 0 PRD. When this document and an ADR disagree, the ADR wins — ADRs are normative, this document is a navigational summary.

---

## 1. What we're building

**Sorvete** is a hybrid commerce platform combining:

- An **Uber-Eats-style multi-merchant marketplace** (Customers browse across many Merchants, place orders, get delivery or pickup).
- A **Square-style merchant-operations SaaS** (Merchants manage their business — Catalog, Inventory, POS, KDS, Staff, Payouts, Analytics, Marketing).
- A **FreshKDS-style kitchen display** for prep-fulfillment workflows.

Verticals supported from day one (data-model wise): restaurants, groceries, butcher shops, convenience stores, retail. v1 features ship restaurant-first; other verticals deepen wave-over-wave.

Markets supported from day one: **card-economy** (US, EU, etc.) and **cash-economy** (Somalia, Lebanon, Iraq, Egypt, Pakistan, Kenya, Nigeria, Bangladesh, …). Sanctioned markets (Syria) are excluded — see ADR-0004.

The platform is built as **32 microservices** (plus a shared `tax` library) running on **Serverpod** (Dart), each owning its own **Postgres** database, deployed on a single **Dokploy VPS**, communicating via **Serverpod typed clients** (synchronous) and **NATS JetStream** (asynchronous via the outbox pattern). The 6 client surfaces are **Flutter apps** (Customer / Merchant / Driver / POS / KDS / Admin) shipped as web (Dokploy + nginx) and native mobile (iOS / Android).

The build proceeds in **7 vertical-slice waves** (Wave 0 — Skeleton → Wave 6 — Public launch), with TDD / E2E / SOLID / DRY / KISS enforced by CI from Wave 0 onward. See ADR-0005.

---

## 2. The stack

### Frontend

| Concern             | Choice                                                                                       |
| ------------------- | -------------------------------------------------------------------------------------------- |
| Framework           | **Flutter** (Dart 3.11+) — single codebase across web, iOS, Android, macOS, Windows, Linux   |
| State management    | **flutter_bloc** + `get_it` for DI                                                           |
| Routing             | **go_router** + `go_router_builder`                                                          |
| Backend client      | **Serverpod typed clients** (auto-generated per service)                                     |
| Local storage       | **Drift on SQLite** (Wave 5 in POS); `shared_preferences` for lightweight config             |
| Offline sync        | **`packages/sync`** custom engine (Wave 5 implementation; API contracts present from Wave 0) |
| Design system       | Custom — see `DESIGN.md`. Fonts: Fraunces (display) + Instrument Sans (body)                 |
| i18n                | **slang** + `slang_flutter` (English from Wave 0; Arabic + RTL from Wave 3)                  |
| Web hosting         | **nginx** static-serve from Dokploy containers                                               |
| Mobile distribution | App Store (iOS) + Play Store (Android)                                                       |

### Backend

| Concern                | Choice                                                                |
| ---------------------- | --------------------------------------------------------------------- |
| Service framework      | **Serverpod** (Dart on server) — one project per bounded context      |
| Service decomposition  | **32 services** + 1 shared `tax` library, across 5 tiers (see §4)     |
| Database (per service) | **Postgres 18** (`pgvector/pgvector:pg18` image) — one database per service container |
| Geospatial             | **PostGIS** required on `geo`'s Postgres (⚠ not yet in the shared `pgvector` image — infra gap) |
| Migrations             | Serverpod migrations per service, independent cadence                 |
| Inter-service sync     | Serverpod-generated typed HTTPS clients                               |
| Inter-service async    | **NATS JetStream** — one stream per source service via outbox pattern |
| Search                 | **Meilisearch** (self-hosted, OSS)                                    |
| Cache                  | **Valkey** (OSS Redis-compatible fork)                                |
| Object storage         | **MinIO** (S3-compatible, self-hosted)                                |
| Analytics warehouse    | **ClickHouse** (OSS columnar) — projections from event stream         |
| Tax                    | **`packages/tax`** shared library (not a service)                     |

### Infrastructure & ops

| Concern                     | Choice                                                        |
| --------------------------- | ------------------------------------------------------------- |
| Container runtime           | **Docker** + Docker Compose                                   |
| Deploy target               | **Dokploy** on a single VPS (scalable to multi-host later)    |
| Image registry              | **GHCR** (GitHub Container Registry)                          |
| Secrets                     | **Infisical** (self-hosted, OSS)                              |
| Logs / metrics / traces     | **LGTM stack**: Loki + Grafana + Tempo + Prometheus (all OSS) |
| Error tracking              | **GlitchTip** (OSS Sentry-compatible)                         |
| Geocoding (self-host)       | **Nominatim** (OSM-backed)                                    |
| Routing (self-host)         | **OpenRouteService** or **Valhalla**                          |
| Email transport (self-host) | **Postal** (SMTP/HTTP)                                        |
| CI/CD                       | **GitHub Actions** → GHCR → Dokploy webhook                   |

### Mandatory paid third-party integrations

Per ADR-0004 — these cannot be built or self-hosted.

| Concern                     | Vendor                                                                                             |
| --------------------------- | -------------------------------------------------------------------------------------------------- |
| Card processing             | **Stripe Connect** (Standard/Express accounts, marketplace pattern)                                |
| SMS gateway                 | **Twilio**                                                                                         |
| Push notifications          | **FCM** (Android) + **APNs** (iOS) — both free, vendor-locked                                      |
| KYC / identity verification | **Sumsub** (global default) + **Smile ID** (African markets) + manual queue (low-document markets) |
| WhatsApp                    | **Twilio WhatsApp Business API**                                                                   |
| Mobile money                | **EVC Plus / Zaad** (Somalia) · **M-Pesa** (Kenya, expansion-ready) · others per market            |

---

## 3. The big picture

```
                  ┌─────────────────────────────────────────────────────────────┐
                  │                          END USERS                          │
                  │   Customer · Merchant · Driver · Staff · Platform Admin     │
                  └─────────────────────────────────────────────────────────────┘
                                              │
       ┌──────────────────────────────────────┼──────────────────────────────────────┐
       ▼                                      ▼                                      ▼
 ┌───────────────┐                  ┌──────────────────┐                  ┌──────────────────┐
 │   Web apps    │                  │    iOS apps      │                  │  Android apps    │
 │   (Flutter    │                  │    (Flutter,     │                  │   (Flutter,      │
 │    + nginx,   │                  │     App Store)   │                  │    Play Store)   │
 │    Dokploy)   │                  │                  │                  │                  │
 └───────────────┘                  └──────────────────┘                  └──────────────────┘
       │                                      │                                      │
       └──────────────────────────────────────┼──────────────────────────────────────┘
                                              │
                                  HTTPS · Serverpod typed clients
                                  HTTPS streams (sync, live KDS, live Driver)
                                              │
                                              ▼
 ╔══════════════════════════════════════════════════════════════════════════════════════════╗
 ║                            DOKPLOY VPS (single host)                                     ║
 ║                                                                                          ║
 ║   ┌────────────────────────────────────────────────────────────────────────────────┐     ║
 ║   │              32 SERVERPOD SERVICES — one container per service                 │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 0 — Foundation                                                          │     ║
 ║   │     identity · merchant · device · media · geo · config                        │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 1 — Commerce core                                                       │     ║
 ║   │     catalog · inventory · pricing · promotions · loyalty · gift_cards          │     ║
 ║   │     ordering                                                                   │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 2 — Money & risk                                                        │     ║
 ║   │     payments · payouts · wallet · disputes · risk · kyc                        │     ║
 ║   │       (+ packages/tax shared library)                                          │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 3 — Fulfillment                                                         │     ║
 ║   │     kitchen · fulfillment · reservations                                       │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 4 — Engagement, discovery, growth                                       │     ║
 ║   │     search · recommendations · reviews · ads · marketing · notifications       │     ║
 ║   │                                                                                │     ║
 ║   │   Tier 5 — Platform & ops                                                      │     ║
 ║   │     webhooks · analytics · audit · support                                     │     ║
 ║   └────────────────────────────────────────────────────────────────────────────────┘     ║
 ║         │              │                  │                │                │            ║
 ║         │ sync REST    │ async events     │ object store   │ cache          │ secrets    ║
 ║         ▼              ▼                  ▼                ▼                ▼            ║
 ║   ┌──────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐    ║
 ║   │ 32×      │  │     NATS     │  │    MinIO     │  │    Valkey    │  │  Infisical  │    ║
 ║   │ Postgres │  │  JetStream   │  │ S3-compatible│  │ Redis-compat │  │   secrets   │    ║
 ║   │ (one DB  │  │   (outbox    │  │   storage    │  │              │  │             │    ║
 ║   │ per svc) │  │    relay)    │  │              │  │              │  │             │    ║
 ║   └──────────┘  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘    ║
 ║                                                                                          ║
 ║   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐     ║
 ║   │ Meilisearch  │ │  ClickHouse  │ │  Nominatim   │ │ OpenRouteSvc │ │   Postal   │     ║
 ║   │    search    │ │   analytics  │ │  geocoding   │ │   routing    │ │ self-host  │     ║
 ║   │              │ │              │ │              │ │              │ │    SMTP    │     ║
 ║   └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘     ║
 ║                                                                                          ║
 ║   ┌────────────────────────────────────────────────────────────────────────────────┐     ║
 ║   │            OBSERVABILITY — LGTM stack + GlitchTip                              │     ║
 ║   │            Loki (logs) · Grafana (dashboards) · Tempo (traces)                 │     ║
 ║   │            Prometheus (metrics) · GlitchTip (errors)                           │     ║
 ║   └────────────────────────────────────────────────────────────────────────────────┘     ║
 ╚══════════════════════════════════════════════════════════════════════════════════════════╝
                                              │
                              outbound — third-party integrations
                                              │
   ┌──────────────┬──────────────┬────────────┴────────────┬──────────────┬─────────────┐
   ▼              ▼              ▼                         ▼              ▼             ▼
 ┌────────┐   ┌────────┐   ┌──────────┐              ┌──────────┐   ┌──────────┐   ┌─────────┐
 │ Stripe │   │ Twilio │   │FCM + APNs│              │  Sumsub  │   │  Mobile  │   │   OSM   │
 │Connect │   │  SMS   │   │  push    │              │ Smile ID │   │  Money   │   │  tiles  │
 │ cards  │   │  WApp  │   │          │              │   KYC    │   │ EVC Plus │   │  (free) │
 │        │   │        │   │          │              │          │   │ M-Pesa   │   │         │
 └────────┘   └────────┘   └──────────┘              └──────────┘   └──────────┘   └─────────┘
```

---

## 4. The 32-service catalog

Quick reference. Full justification in **ADR-0003**.

| Tier | Service                  | Owns                                               | Wave first activated             |
| ---- | ------------------------ | -------------------------------------------------- | -------------------------------- |
| 0    | `identity`               | Users, credentials, sessions, JWT issuance         | 0                                |
| 0    | `merchant`               | Merchant, Location, Staff, settings, vertical      | 0                                |
| 0    | `device`                 | POS / KDS pairing, device registry                 | 0                                |
| 0    | `media`                  | Image upload, CDN signing                          | 0                                |
| 0    | `geo`                    | Address validation, delivery zones (PostGIS)       | 0                                |
| 0    | `config`                 | In-house feature flags                             | 0                                |
| 1    | `catalog`                | Product, Variant, Modifier, Category               | 0                                |
| 1    | `inventory`              | Stock per Variant per Location, 86 flag            | 0                                |
| 1    | `pricing`                | Tax + surge + fee math, line-item Money quotes     | 0                                |
| 1    | `promotions`             | Coupons, deals, BOGO                               | 0 (stub) · 4 (deep)              |
| 1    | `loyalty`                | Points, tiers, rewards                             | 0 (stub) · 4 (deep)              |
| 1    | `gift_cards`             | Codes & redemption (built on `wallet`)             | 0 (stub) · 4 (deep)              |
| 1    | `ordering`               | Cart, Order, OrderLine, state machine              | 0                                |
| 2    | `payments`               | Payment Method Adapter (Stripe first)              | 0                                |
| 2    | `payouts`                | Merchant payouts, statements                       | 0 (stub) · 5 (deep)              |
| 2    | `wallet`                 | Double-entry ledger (Customer / Merchant / Driver) | 0 (schema) · 3 (active)          |
| 2    | `disputes`               | Chargebacks, refund disputes                       | 0 (stub) · 5 (deep)              |
| 2    | `risk`                   | Fraud signals, velocity, holds                     | 0 (basic) · 5 (deep)             |
| 2    | `kyc`                    | Provider-pluggable verification                    | 0 (stub) · 3 (active)            |
| 3    | `kitchen`                | KDS tickets, prep state, bump times                | 0 (consumer) · 1 (deep)          |
| 3    | `fulfillment`            | Driver pool, dispatch, ETA, route                  | 0 (stub) · 2 (deep)              |
| 3    | `reservations`           | Table booking, appointments                        | 0 (stub) · 4 (deep)              |
| 4    | `search`                 | Meilisearch-backed product/merchant search         | 0 (stub) · 2 (deep)              |
| 4    | `recommendations`        | Personalization, "order again"                     | 0 (stub) · 4 (deep)              |
| 4    | `reviews`                | Customer ratings & responses                       | 0 (stub) · 4 (deep)              |
| 4    | `ads`                    | Sponsored listings, auctions, billing              | 0 (stub) · 4 (deep)              |
| 4    | `marketing`              | Email/SMS/WhatsApp campaigns, segments             | 0 (stub) · 4 (deep)              |
| 4    | `notifications`          | Transactional push/email/SMS/WhatsApp              | 0 (email) · waves add transports |
| 5    | `webhooks`               | Outbound merchant integrations                     | 0 (stub) · 5 (deep)              |
| 5    | `analytics`              | ClickHouse projections, dashboards                 | 0 (stub) · 5 (deep)              |
| 5    | `audit`                  | Immutable event log, compliance exports            | 0                                |
| 5    | `support`                | CS tickets, dispute escalation                     | 0 (stub) · 5 (deep)              |
| —    | `packages/tax` (library) | `(jurisdiction, lines) → Money` tax math           | 0 (returns 0%) · 5 (multi-juris) |

---

## 5. The 6 client apps

| App             | Audience                               | Wave first interactive   | Key offline needs               |
| --------------- | -------------------------------------- | ------------------------ | ------------------------------- |
| `apps/customer` | End customers browsing the marketplace | 0                        | None — online required          |
| `apps/merchant` | Merchant owner & permitted Staff       | 0                        | None — online required          |
| `apps/pos`      | Staff at a paired POS Terminal         | 0 (online) · 5 (offline) | **Yes — first-class offline**   |
| `apps/kds`      | Kitchen staff at a paired KDS Display  | 1                        | Light (Wave 5+)                 |
| `apps/driver`   | Couriers (platform pool + in-house)    | 2                        | Light (poor coverage tolerance) |
| `apps/admin`    | Platform operators                     | 5                        | None — online required          |

All 6 apps build from one Flutter codebase and share the per-service generated Serverpod clients plus **`packages/backend`** — today the single shared package, holding the idempotency-key generator, typed error envelope, service registry, auth-key manager, config/URL resolver, and health dashboard.

> **Doc vs. reality (Wave 0):** the planned split into `packages/ui` (design system, `DESIGN.md`), `packages/core` (Money/Currency/UUID v7/errors), `packages/i18n` (slang), and `packages/sync` (offline mutation engine, Wave 5) is **not yet created**. Those primitives currently live in `packages/backend`. `Money`/`Currency` do not exist yet at all — creating them is Wave 0 work.

---

## 6. How a request flows — the happy path

Customer placing one Order with one Product, paid by Stripe card, accepted at POS:

```
Customer App (Flutter)
     │
     │ 1. signUp(email, password, idempotency_key)
     ▼
  [identity] ──→ User row + JWT issued
     │
     │   emits UserCreated → NATS → consumers: [audit], [marketing]
     │
     │ 2. browseProducts(locationId)
     ▼
  [catalog] ──→ Product list (cached in Valkey for read-through)
     │
     │ 3. createCart(customerId, merchantId, locationId, idempotency_key)
     │ 4. addCartLine(cartId, variantId, qty, modifiers, idempotency_key)
     ▼
  [ordering] ──→ Cart in memory + DB
     │
     │ 5. server-to-server: priceCart(cartSnapshot, idempotency_key)
     ▼
  [pricing] ──┬─→ packages/tax.taxOnQuote(jurisdiction, lines) → Money
              ├─→ [promotions].evaluate(cart) → []
              └─→ returns Quote { subtotal, tax, fees, total } in Money
     │
     │ 6. checkout(cartId, paymentMethod=card_stripe, idempotency_key)
     ▼
  [ordering] ──→ creates Order in state PLACED
     │
     │ 7. server-to-server: [payments].createIntent(orderId, card_stripe, idempotency_key)
     ▼
  [payments] ──→ StripeConnectAdapter.initiate() ──→ Stripe API (test mode)
                                                      │
                                                      ▼
                                            PaymentIntent confirmed
                                                      │
                                                      ▼
                          emits PaymentCaptured → NATS → [ordering] subscriber
     │
     │ 8. on PaymentCaptured, [ordering] transitions Order to ACCEPTED
     │    emits OrderPlaced → NATS
     │      consumers:
     │        [inventory] decrements stock (server-authoritative)
     │        [audit] appends immutable event
     │        [notifications] sends receipt via Postal (email transport)
     │        [kitchen] (Wave 1+) creates Ticket if Location is kitchen_prep
     │        [analytics] projects to ClickHouse
     │
     ▼
Merchant POS App (paired, online)
     │
     │ 9. acceptOrder(orderId, deviceToken, idempotency_key)
     ▼
  [ordering] ──→ state PREPARING → READY → COMPLETED
     │
     │   each transition emits an event → NATS → audit + downstream
     │
     ▼
Customer App receives push (Wave 1+) and email ("your order is complete")
```

**Every mutating call carries an `idempotency_key`. Every state transition emits to NATS via the outbox. The `audit` service has a complete forensic record.**

---

## 7. How async events flow — the outbox pattern

Every service's writes are atomic across (a) the domain table and (b) a local `outbox` table. A relay loop ships outbox rows to NATS JetStream; consumers in other services read durable consumers.

```
   ┌─────────────────────────────────────┐
   │       service: ordering             │
   │                                     │
   │   ┌───────────────────────────────┐ │
   │   │       Postgres (ordering_db)  │ │
   │   │                               │ │
   │   │  ┌─────────────┐              │ │
   │   │  │  orders     │◀─────┐       │ │
   │   │  │  order_lines│      │       │ │       ┌────────────────────────┐
   │   │  └─────────────┘      │       │ │       │   Endpoint handler     │
   │   │                       │ tx    │ │ ◀──── │   (single transaction) │
   │   │  ┌─────────────┐      │       │ │       │                        │
   │   │  │  outbox     │◀─────┘       │ │       │   1. UPDATE orders     │
   │   │  └─────────────┘              │ │       │   2. INSERT outbox     │
   │   │       │                       │ │       │   3. COMMIT            │
   │   └───────┼───────────────────────┘ │       └────────────────────────┘
   │           │                         │
   │           │ relay (1s poll)         │
   │           ▼                         │
   │   ┌───────────────────────────────┐ │
   │   │       OutboxRelay             │ │
   │   │       publish → NATS          │ │
   │   │       mark published_at       │ │
   │   └───────────────────────────────┘ │
   └─────────────────┬───────────────────┘
                     │
                     ▼
              ┌───────────────┐
              │ NATS JetStream│
              │  stream:      │
              │  outbox.ordering
              └───────────────┘
                     │
   ┌─────────────────┼─────────────────┬─────────────────┐
   ▼                 ▼                 ▼                 ▼
┌─────────────┐  ┌──────────┐    ┌────────────┐   ┌─────────────┐
│ inventory   │  │  audit   │    │notifications│  │  analytics  │
│ consumer    │  │ consumer │    │  consumer  │   │  consumer   │
│ "inv-from-  │  │ "audit-  │    │ "notif-    │   │ "analytics- │
│  ordering"  │  │  from-   │    │  from-     │   │  from-      │
│             │  │ ordering"│    │  ordering" │   │  ordering"  │
└─────────────┘  └──────────┘    └────────────┘   └─────────────┘
```

**Guarantee**: an event in the outbox is shipped exactly once (NATS JetStream deduplication window) and processed at least once by each consumer (durable consumers + ack semantics). Consumers are idempotent on event_id to handle retries.

---

## 8. Offline POS — the local-first stack

POS works offline (Wave 5 activation). Cloud-side API contracts (idempotency, UUID v7 PKs, past-dated timestamps, conflict signals) are enforced from Wave 0 so the offline engine can land later without API rewrites.

```
  POS App (iPad / Mac / Windows / Linux Flutter build)
  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │   Flutter UI (orders / payments / catalog browse)   │
  │                       │                             │
  │                       ▼                             │
  │   ┌─────────────────────────────────────────────┐   │
  │   │       packages/sync (Wave 5)                │   │
  │   │   - mutation queue                          │   │
  │   │   - idempotency-key generator (UUID v7)     │   │
  │   │   - replay engine                           │   │
  │   │   - server-pushed subscription consumer     │   │
  │   │   - conflict surfacing                      │   │
  │   └─────────────────────────────────────────────┘   │
  │                       │                             │
  │                       ▼                             │
  │   ┌─────────────────────────────────────────────┐   │
  │   │       Drift (SQLite)  —  local-first store  │   │
  │   │                                             │   │
  │   │   - cached Catalog snapshot                 │   │
  │   │   - open Orders                             │   │
  │   │   - pending mutations queue                 │   │
  │   │   - last-sync metadata                      │   │
  │   └─────────────────────────────────────────────┘   │
  │                                                     │
  └─────────────────────────────────────────────────────┘
                          │
                          │   when online:
                          │   • pull catalog snapshot from [catalog]
                          │   • push pending mutations w/ idempotency_key
                          │   • subscribe Serverpod stream for incoming events
                          ▼
   ┌─────────────────────────────────────────────────────┐
   │   Cloud — Serverpod services                        │
   │                                                     │
   │   [ordering]    client-authoritative — accepts      │
   │                 past-dated orders; dedup via key    │
   │   [payments]    cash adapters client-authoritative; │
   │                 card requires online                │
   │   [wallet]      ledger entries dedup via key        │
   │   [inventory]   SERVER-authoritative — raises       │
   │                 oversell conflict on mismatch       │
   │   [catalog]     SERVER-authoritative — POS holds    │
   │                 read-only mirror                    │
   └─────────────────────────────────────────────────────┘
                          │
                          │  on conflict:
                          ▼
   ┌─────────────────────────────────────────────────────┐
   │  POS shows ConflictModal                            │
   │  Merchant chooses resolution (refund / fulfill /    │
   │  substitute / cancel)                               │
   │  Outcome → [audit] for forensic record              │
   └─────────────────────────────────────────────────────┘
```

Status badge on POS: 🟢 online+synced · 🟡 online+N pending · 🔴 offline+N pending. Tap for the sync queue.

Offline duration tolerance: **24h soft warning · 72h hard cutoff** (configurable per Merchant).

---

## 9. The payment universe — Adapter pattern

`payments` is built around a uniform Payment Method Adapter contract — `initiate · confirm · refund · reconcile`. Each method is one adapter; adding a country / method is one adapter, not a service rewrite.

```
   ┌────────────────────────────────────────────────────────────────┐
   │   service: payments                                            │
   │                                                                │
   │   ┌────────────────────────────────────────────────────────┐   │
   │   │       PaymentMethodAdapter (interface)                 │   │
   │   │         initiate(intent) → AdapterState                │   │
   │   │         confirm(state)   → AdapterState                │   │
   │   │         refund(captured) → RefundResult                │   │
   │   │         reconcile(state) → ReconciliationResult        │   │
   │   └────────────────────────────────────────────────────────┘   │
   │              ▲             ▲             ▲             ▲       │
   │              │             │             │             │       │
   │   ┌──────────┴───┐ ┌───────┴────┐ ┌──────┴─────┐ ┌─────┴────┐  │
   │   │card_stripe   │ │wallet_     │ │cash_at_    │ │cash_on_  │  │
   │   │              │ │balance     │ │pickup      │ │delivery  │  │
   │   │Stripe Connect│ │ledger      │ │POS         │ │Driver +  │  │
   │   │API           │ │debit       │ │collection  │ │OTP +     │  │
   │   │              │ │            │ │            │ │remit     │  │
   │   └──────────────┘ └────────────┘ └────────────┘ └──────────┘  │
   │   ┌──────────────┐ ┌────────────┐ ┌────────────┐ ┌──────────┐  │
   │   │mobile_money_ │ │mobile_money│ │mobile_money│ │bank_     │  │
   │   │evc           │ │_zaad       │ │_mpesa      │ │transfer_ │  │
   │   │              │ │            │ │            │ │local     │  │
   │   │EVC Plus      │ │Telesom Zaad│ │Safaricom   │ │statement │  │
   │   │Hormuud       │ │Somaliland  │ │M-Pesa      │ │matching  │  │
   │   └──────────────┘ └────────────┘ └────────────┘ └──────────┘  │
   └────────────────────────────────────────────────────────────────┘
```

`ordering` doesn't know or care which adapter is in play — it sees a uniform PaymentIntent state machine.

---

## 10. Cross-cutting disciplines (enforced from Wave 0)

Per ADR-0005 + ADR-0006. These apply to **every service**.

- **TDD red-green-refactor.** CI rejects PRs whose code diff isn't matched by proportional test diff.
- **E2E per wave.** Each wave's CI pipeline runs a happy-path E2E across all touched services on an ephemeral Docker Compose. Wave 0 ships the first.
- **SOLID at the service boundary.** One bounded reason to change per service. Adapters DI-injected. No service touches another service's DB or internals.
- **DRY via `packages/*`.** Money, Currency, UUID v7, error envelopes, idempotency middleware, outbox writer, audit emitter, ledger primitives live as shared packages — never duplicated.
- **KISS per wave.** No service or feature lands earlier than its wave. No speculative abstractions.
- **Idempotency-key mandatory** on every mutating endpoint across all 32 services. 30-day server-side cache.
- **UUID v7 primary keys everywhere.** Cloud-generated and offline-generated.
- **Past-dated timestamps tolerated** on every mutating endpoint (with documented acceptance bounds).
- **Outbox pattern** on every domain event. No event is emitted outside a transaction.
- **Money is always currency-typed.** No implicit USD anywhere; cross-currency operations throw at compile time.
- **Conflict-aware writes.** Server-side merge policy per entity, documented per service. POS surfaces conflicts to Merchant in the ConflictModal.

---

## 11. Build sequence

Per ADR-0005. Each wave deepens **every** service that it touches; we don't finish service-by-service.

| Wave  | Theme                                     | What lands                                                                                                                                           |
| ----- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **0** | Skeleton walking                          | All 32 services scaffolded, all 32 Postgres DBs, full infra stack, CI/CD, observability, happy-path E2E. Stripe (test mode), email receipts.         |
| **1** | Restaurant vertical, US, dine-in & pickup | KDS service + app, Variants/Modifiers, Inventory tracking, Refunds, FCM/APNs push, POS app (online), Device pairing. Closed alpha with one Merchant. |
| **2** | Marketplace + delivery                    | Driver app, `fulfillment` deep, `geo` deep, multi-merchant browse, multiple concurrent Carts, `search` (Meilisearch), Twilio SMS.                    |
| **3** | Cash economy + first emerging market      | `wallet` active, Cash-on-Delivery + OTP, Cash-at-Pickup, EVC Plus, WhatsApp, Arabic + RTL, `kyc` providers, Driver cash float, Merchant Settlement.  |
| **4** | Engagement & monetization                 | `promotions`, `loyalty`, `gift_cards`, `ads`, `marketing`, `reviews`, `reservations`, `recommendations` — all deep.                                  |
| **5** | Compliance, payouts, ops, offline POS     | `disputes`, `payouts`, `audit` full, `risk` ML, `support`, `webhooks`, `analytics` deep, multi-juris tax. **Offline POS sync engine ships.**         |
| **6** | Parity launch                             | Multi-market (US + EU + 2–3 cash markets), self-service POS, multi-location merchants, perf/cost tuning, A/B infra, public launch.                   |

---

## 12. Where to look for what

| Question                                                | File                                                     |
| ------------------------------------------------------- | -------------------------------------------------------- |
| What does the domain _mean_? Canonical terms?           | `CONTEXT.md`                                             |
| Why microservices instead of a monolith?                | `docs/adr/0001-microservices-with-serverpod.md`          |
| Why one DB per service?                                 | `docs/adr/0002-database-per-service.md`                  |
| Why these 32 services? Why is X folded into Y?          | `docs/adr/0003-service-catalog.md`                       |
| Why cash flows, and why is Syria excluded?              | `docs/adr/0004-cash-economy-from-day-one.md`             |
| Why vertical-slice waves? Why TDD-enforced from Wave 0? | `docs/adr/0005-vertical-slice-waves-and-discipline.md`   |
| Why Drift + custom sync? Why UUID v7 everywhere?        | `docs/adr/0006-offline-pos-sync-model.md`                |
| What's in Wave 0?                                       | GH issue [#1](https://github.com/zxcvbnmmohd/sorvete/issues/1) — Wave 0 PRD |
| What does the UI look like?                             | `DESIGN.md`                                              |

When this document conflicts with an ADR, the ADR wins. When this document conflicts with `CONTEXT.md` on domain terms, `CONTEXT.md` wins.
