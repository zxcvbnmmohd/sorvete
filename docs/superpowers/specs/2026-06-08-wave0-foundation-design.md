# Wave 0 Foundation — Shared Packages + Test Harness (Layer A)

> Design spec. Lays the cross-cutting rails (DRY/KISS/SOLID) and the TDD + live-E2E
> test infrastructure **before** any domain model or app screen. First slice of
> GH issue [#1](https://github.com/zxcvbnmmohd/sorvete/issues/1) (Wave 0 PRD),
> deliberately stopping before domain logic and full service rollout.
>
> Normative sources: ADR-0001 (microservices), ADR-0003 (32-service catalog),
> ADR-0004 §8 (currency-typed money), ADR-0005 (prove integration contracts at
> Wave 0), ADR-0006 (idempotency/UUID v7 from Wave 0). When this doc and an ADR
> disagree, the ADR wins.

## Goal & non-goals

**Goal:** on the current blank slate (32 stock Serverpod scaffolds, one Flutter
client SDK, no domain code), build the shared foundations and a self-proving test
harness so that feature work can begin on solid rails.

**Non-goals (Layer A boundary):**

- No domain models (no Cart/Order/Product/etc.), no business endpoints, no app UI.
- `server_kit` wired into **2 pilot services only** (`identity`, `audit`) — rollout
  to all 32 is deferred to the domain wave.
- `packages/tax` **deferred** — pure stub with no consumer yet (`pricing` absent); YAGNI.
- No payments/pricing, no observability stack (LGTM/GlitchTip), no
  Meilisearch/MinIO/ClickHouse/Infisical.
- **No rename** of `packages/backend` (its name is misleading — it is the client
  SDK, not the server). Flagged, deferred as unrelated churn.

## Architecture — three packages by consumer type

The load-bearing rule: **dependency direction flows one way, `pure → (client | server)`,
and Flutter never reaches a server.** A Serverpod server is pure Dart; it must not
inherit Flutter. This is verified today: `packages/backend` depends on Flutter and
bundles all 32 client packages, and no server depends on it.

| Package | Dependency surface | Holds | Consumed by |
|---|---|---|---|
| **`packages/core`** *(new)* | Pure Dart (`test`, `freezed`, `json_*`, `uuid`) — no Flutter, no Serverpod | `Money`, `Currency`, `Ids`, `AppError`, `OutboxEvent`, `PastDatedTimestamp` | everything |
| **`packages/backend`** *(exists, `sorvete_backend`)* | Flutter + `serverpod_client` | 32-client aggregator, auth-key manager, service registry, config/URL resolver, health widgets, `mapServerpodError` | the 6 apps |
| **`packages/server_kit`** *(new)* | Pure Dart + `serverpod` (server) | `OutboxWriter`, `OutboxRelay`, `EventPublisher`, `NatsBus`, `IdempotencyStore`, `EventConsumer`, endpoint guard mixins | each service server |

`packages/backend` adds a dep on `core` and **re-exports** the relocated types
(`AppError`, `IdempotencyKey`/`Ids`, `PastDatedTimestamp`) so app imports do not break.

## Coding conventions (apply to all new code)

- **Named parameters** for any function/method/constructor with **2+ params**;
  positional allowed only when exactly 1 param. (E.g. `OutboxWriter.enqueue({required transaction, required event})`,
  `Money.zero(currency)`, `Ids.newId()`.)
- **Codegen first** — `freezed` + `json_serializable` for `core` data types; Serverpod
  model codegen (`.spy.yaml`) for the DB-backed `outbox`/`idempotency_cache` tables;
  `envied` for env. Minimize hand-written boilerplate.
- **`faker` (seeded) in tests** — generate emails/ids/amounts/payloads; assert
  *properties*, not hardcoded fixtures.
- **No hardcoded values** in production code — pull from config/env (envied / Serverpod
  config). Justified exceptions: a literal that *is* the external contract being guarded
  (e.g. a test pinning ports to `docker-compose.dev.yml`), and declared reference-data
  tables (ISO-4217 minor-unit digits) sourced once.

## Modules & interfaces

Interfaces are illustrative (named-param convention applied); exact shapes settle in TDD.

### `packages/core` (pure Dart, freezed)

- **`Money`** — `freezed`; `Money({required int minorUnits, required Currency currency})`.
  Operators `+ - *`; cross-currency `+`/`-` throws `CurrencyMismatch`. `Money.zero(Currency currency)`.
  Formatting by `currency.minorUnitDigits`. (ADR-0004 §8: no implicit USD.)
- **`Currency`** — `freezed` value object: ISO-4217 `code` + `minorUnitDigits`, from a
  single declared reference table.
- **`Ids`** — `Ids.newId()` → UUID v7 (time-ordered, offline-safe). `IdempotencyKey` kept
  as a named alias for source-compat.
- **`AppError`** — `freezed` sealed union (relocated from `backend`): the existing cases
  (`Unauthenticated`, `Forbidden`, `Conflict`, `NotFound`, `RateLimited`, `Server`, `Network`).
- **`OutboxEvent`** — `freezed` + json:
  `OutboxEvent({required UuidValue id, required String type, required UuidValue aggregateId, required DateTime occurredAt, required Map<String,dynamic> payload, DateTime? publishedAt})`.
- **`PastDatedTimestamp`** — acceptance-bound helpers (relocated).

### `packages/server_kit` (Serverpod server module)

Deep modules behind ports — the SOLID seams that make them unit-testable without I/O.

- **`OutboxWriter`** — `enqueue({required Transaction transaction, required OutboxEvent event})`
  writes to the `outbox` table inside the caller's transaction (atomic with the domain write).
- **`EventPublisher`** (interface) — `publish({required String subject, required OutboxEvent event})`.
  Impls: `NatsEventPublisher` (real), `FakeEventPublisher` (tests).
- **`OutboxRelay`** — polls unpublished `outbox` rows → `EventPublisher.publish` → marks
  `publishedAt`. Re-attempts on publish failure; never double-publishes a published row.
  NATS subjects: `outbox.<sourceService>` (ARCHITECTURE.md §7).
- **`NatsBus`** — connect / publish / durable-subscribe wrapper.
- **`IdempotencyCacheRepo`** (interface) — store/lookup `{key → response}`. Impls: in-memory
  (tests), Postgres-backed (prod).
- **`IdempotencyStore`** — `runOnce<T>({required String key, required Future<T> Function() action})`:
  first call runs + caches; replay within the 30-day window returns the cached response.
  Also keys consumer dedup on `event_id`.
- **`EventConsumer`** base — durable NATS consumption, idempotent on `event_id` via
  `IdempotencyStore`.
- **Endpoint guard mixins** — require an idempotency key + tolerate past-dated timestamps,
  applied uniformly to mutating endpoints.

**Serverpod-module decision:** `server_kit` is a Serverpod **server module** so its
`outbox` + `idempotency_cache` tables, the relay, and the guards mix into a service via
one dependency (DRY) rather than each service re-declaring them. Fallback if the module
path proves awkward: per-service table declarations consuming `server_kit`'s logic classes.

## Test strategy

### TDD unit layer (fast, no I/O; runs under `melos run test` + per-service matrix)

- **`core`**: `Money` (arithmetic, `CurrencyMismatch` throws, `zero`, formatting),
  `Currency`, `Ids` (UUID v7 shape + time-ordering), `OutboxEvent` (JSON round-trip),
  `PastDatedTimestamp` (acceptance bounds).
- **`server_kit`**: `OutboxWriter` (enqueues within the given transaction — fake tx + repo),
  `OutboxRelay` (publishes unpublished via `FakeEventPublisher`, marks `publishedAt`,
  re-attempts on failure, no double-publish), `IdempotencyStore` (first runs, replay cached,
  keys isolated, window respected), `EventConsumer` (dedups on `event_id`).
- Data via **seeded `faker`**; property-style assertions.
- Prior art: `packages/backend/test/*` (pure `flutter_test`); `serverpod_test_tools` in
  `services/*/server/test/integration/`.

### Live E2E (the async-rail proof) — new top-level `e2e/` package

Test-only package (not in any app/server build). In CI **and** locally (`melos run e2e`),
boots an ephemeral Docker Compose: **NATS + `identity` + `audit` servers + their Postgres**,
then runs one test proving three rails:

1. **Sync rail** — typed-client call to `identity` health/greeting succeeds; auth
   (sign-up → sign-in → JWT) works.
2. **Async rail** — call a **guarded `emitTestEvent` infra endpoint** on `identity`
   (provided by `server_kit`, registered **only in dev/test run-mode**, never production) →
   it enqueues a synthetic `OutboxEvent` → `OutboxRelay` ships it to NATS → `audit`'s
   `EventConsumer` receives + records it → the test polls `audit` and asserts arrival.
3. **Dedup** — emit the same `event_id` twice → assert `audit` applied it exactly once.

This E2E is the permanent regression test for the event backbone; every future service
reuses the pattern when its real events land.

### CI + infra wiring

- Add a **NATS JetStream** container to `docker-compose.yml` and `docker-compose.dev.yml`.
- Add an **`e2e` job** to `.github/workflows/ci.yml` (`needs: [analyze, test]`):
  compose up (NATS + 2 servers + 2 Postgres) → run `e2e` → tear down.
- Add **`melos run e2e`** for local parity with CI.

## Build sequence (TDD throughout — tests first)

1. **`packages/core`** — pure types via freezed, unit-tested red→green. Re-point
   `packages/backend` to re-export relocated types; confirm `apps/admin` still resolves.
2. **`packages/server_kit`** — deep modules behind ports (with fakes), unit-tested; then
   the real `NatsEventPublisher`/`NatsBus`/Postgres repo impls.
3. **Infra** — NATS in both compose files + `melos run e2e`.
4. **Pilot wiring** — `server_kit` module into `identity` + `audit`; guarded `emitTestEvent`
   endpoint + `audit` consumer; `outbox` + `idempotency_cache` tables via the module.
5. **`e2e/` package + CI `e2e` job.**

## Success criteria

- `melos run test` green, including new `core` + `server_kit` isolation suites.
- `melos run e2e` and the CI `e2e` job green — sync + async + dedup proven on **real NATS**.
- `apps/admin` still builds after the `backend` re-export refactor.
- Dependency direction enforced: no Flutter in `core`/`server_kit`; no server depends on
  `packages/backend`.
- New data types are codegen-backed; tests use seeded `faker`; no stray hardcoded values.
