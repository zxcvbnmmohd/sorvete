# config_server

> The light switches. In-house feature flags. Turn things on for 10% of users, kill-switch a broken integration, gate a Wave's worth of features.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 · **Database**: `config` (Postgres)

## What this service owns

- **Flag** — a named boolean / variant / percentage rollout
- **Rule** — targeting predicate (`country=KE`, `merchantId IN (...)`, `userPercent < 10`)
- **Evaluation cache** — short-TTL per `(flag, context)` to avoid per-request Postgres reads

Built in-house — no dependency on Unleash, LaunchDarkly, or Flagsmith (per ADR-0003).

## Responsibilities

- CRUD flags via the Admin app
- Evaluate a flag for a request context `(userId, merchantId, locationId, country, ...)`
- Stream flag changes to subscribed services so caches invalidate instantly
- Expose the same evaluation result for every caller of the same context (deterministic bucketing)

## Out of scope

- **Configuration per Merchant** (currency, timezone, vertical, …) → owned by `merchant`
- **A/B-test analytics** → owned by `analytics` (consumes `FlagEvaluated` events)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `flag.list()` | List all flags + rules (Admin) |
| `flag.create(key, description, defaultValue)` | Define a new flag |
| `flag.update(key, patch)` | Edit rules / default |
| `flag.archive(key)` | Soft-delete |
| `flag.evaluate(key, context)` | Returns the resolved value for this context |
| `flag.evaluateAll(context)` | Batch — returns the full flag map for a context (cache-friendly) |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.config.*`):

- `FlagCreated`, `FlagUpdated`, `FlagArchived`
- `FlagEvaluated` — sampled at low rate for `analytics` cohort tracking

**Consumes**: none.

## Cross-service calls

- **Synchronous**: none
- **Asynchronous**: emits to `audit`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 0)
- `docs/adr/0003-service-catalog.md` — "config is built in-house"
