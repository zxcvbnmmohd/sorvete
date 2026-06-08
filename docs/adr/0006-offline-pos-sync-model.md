# Offline POS sync model

## Context

The POS app must operate offline for 1–8+ hours during network outages, in poor-coverage locations, and from food trucks / pop-ups on cellular hotspots. With 33 microservices each owning their own Postgres, no single "source of truth" exists to sync against — every domain (Orders, Payments, Wallet, Inventory, Catalog) has its own consistency requirements and its own conflict semantics. A uniform sync policy would be a lie; a per-entity policy is the only honest model.

Decisions had to be made about: local-first DB engine, sync engine architecture, ID generation, idempotency, per-entity conflict policy, offline duration tolerance, offline card payment handling, and sync state UX in the POS app.

## Decision

### 1. Local-first DB: **Drift on SQLite**
SQL semantics matching cloud entity shapes, reactive queries for UI binding, mature migration system, build_runner-integrated. Considered and rejected: Isar (maintainer-limbo, uncertain future), Hive (too lightweight for our shape), ObjectBox (licensing concerns).

### 2. Sync engine: **custom Dart package at `packages/sync`**
Considered and rejected: PowerSync (OSS, Postgres-friendly) — assumes a single source-of-truth Postgres. With 33 separate databases across 33 services, PowerSync would require per-service sync-rule configuration and would surrender control over per-entity conflict policy. A custom engine — pull snapshots + push mutations with idempotency + subscribe to server-pushed changes via Serverpod streaming — fits our service shape and reuses the typed clients we already generate.

The engine is built once in `packages/sync` and consumed by every offline-capable client (POS first; Driver and KDS later as their offline needs surface).

### 3. ID generation: **UUID v7, client-generated, used as primary key everywhere**
Time-ordered (DB-index-friendly), offline-safe, 128-bit collision-resistant, no central authority needed. Applies cloud-side too — every entity in every service uses UUID v7 primary keys. Consistency over premature optimization.

### 4. Idempotency: **mandatory client-supplied key on every mutating endpoint; server-stored for 30 days**
The server stores `{idempotency_key → response}` and replays the cached response on duplicate calls. 30 days covers a worst-case offline duration (a POS unplugged over a long weekend). This is a non-negotiable contract from Wave 0 across all 33 services.

### 5. Per-entity conflict resolution policy: **server-side, per-entity, documented per service**

| Entity domain | Policy | Rationale |
|---|---|---|
| Order | **Client-authoritative** | POS is the source of truth for what happened in the shop. Server accepts the offline-replay as-is. |
| Payment (cash / wallet / mobile money pre-paid) | **Client-authoritative** | Same — POS / driver collected the money in reality; cloud accepts the record. |
| Payment (card) | **Online-required** | Card auth is network-dependent. See item 7 below. |
| Inventory | **Server-authoritative** | Cloud is the source of truth for stock. Offline POS may oversell. Conflict signal raised at sync time; merchant resolves via the Conflict modal. |
| Catalog / Prices / Promotions | **Server-authoritative** | POS holds a cached read-only snapshot. Edits happen online via `apps/merchant`. |
| 86 actions | **Bidirectional eventual** | Last-write-wins on the 86-flag itself; merchant sees conflicts at reconciliation (e.g. POS sold while cloud was 86'd). |
| Customer profile | **Server-authoritative** | Server-side updates; POS reads cache. |

### 6. Offline duration tolerance: **24h soft, 72h hard — configurable per Merchant**
- Within 24h: silent.
- 24–72h: persistent warning banner in POS.
- Past 72h: POS refuses to process new orders. Catalog/pricing snapshot is too stale for trust. Merchants who need longer tolerance can raise the threshold knowingly.

### 7. Offline card payments: **not supported until Wave 5 evaluates store-and-forward**
Card payments require online authorization. "Store-and-forward" offline card mode (à la Square Offline Mode) exists but transfers decline risk to the merchant — that is a product decision, not just a technical one. Punted to Wave 5 with the option to add or to skip permanently. Until then: card requires online; cash, wallet, and mobile-money-pre-paid work offline.

### 8. Sync state UX in POS app
- **Persistent status badge**: green (online + synced), amber (online + N pending), red (offline + N pending).
- **Tap → sync queue detail** showing each pending mutation.
- **Non-blocking**: merchant operates regardless of sync state.
- **Conflict modal**: surfaces on reconnect when a conflict was detected (e.g. "You sold 3× chicken sandwich while offline. The kitchen marked it 86 at 11:04. Refund the customer, or fulfill from substitute stock?"). Conflict outcomes are persisted as `audit` events.

## Why

Per-entity conflict resolution is the only honest answer for a system where Orders need client-wins (the shop knows what happened) and Inventory needs server-wins (the cloud knows what's in stock). A uniform "last-write-wins" or uniform "server-wins" policy would lose either real money (orders not synced) or real trust (overselling never surfaced).

Custom sync engine over PowerSync is justified because 33 separate Postgres databases break PowerSync's single-Postgres assumption, and because per-entity policies are easier to express in code we own than in a sync-rules DSL.

UUID v7 client-side is the only ID strategy that survives offline generation without a central authority. Database-generated IDs would require a round-trip per insert, which is fatal for offline.

Idempotency keys are not a "nice to have" — without them, a POS that resubmits after reconnection creates duplicate Orders, double charges, and duplicate inventory decrements.

## Consequences

- **Every mutating endpoint across every service** carries an `idempotency_key` parameter from Wave 0. Non-negotiable.
- **Every entity primary key is UUID v7** — cloud-side and client-side. Postgres `uuid` columns; Drift mirrors them.
- **`packages/sync`** is the SDK for any offline-capable client. POS uses it first; Driver and KDS adopt it as their offline needs land in Wave 5+.
- **Conflict modals are part of the POS app contract** from Wave 5 (when the sync engine itself ships). Conflict resolution is an explicit Merchant action; conflicts are never silently dropped.
- **Conflict outcomes are persisted to `audit`** for compliance and forensic replay.
- **Offline card payments are deferred**; merchants in flaky-network environments must accept that card sales need a brief reconnection window.
- **The local-first Drift schema mirrors the cloud entity shape** but is intentionally a denormalized projection — POS only holds what it needs to operate, not the full domain.

## Status

accepted
