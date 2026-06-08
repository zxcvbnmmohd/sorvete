# audit_server

> The black box flight recorder. Every state-changing event in every service lands here. Append-only, immutable, compliance-grade.

**Tier**: 5 (Platform & ops) · **Wave first activated**: 0 · **Database**: `audit` (Postgres, plus periodic export to MinIO)

## What this service owns

- **AuditEvent** — `(id, source, eventType, occurredAt, actor, subjectRefs, payload)` — append-only
- **ExportArchive** — periodic immutable archives written to MinIO for legal hold
- **RetentionPolicy** — per-event-type retention windows (e.g., financial events: 7 years)
- **AccessLog** — who queried the audit log and what they retrieved

## Responsibilities

- Subscribe to every `outbox.*` NATS stream and persist with `id` + `event_id` as primary key (idempotent)
- Never UPDATE or DELETE — only INSERT
- Provide a queryable, paginated view by `(source, eventType, actor, subjectRef, time range)` to Admin / Support
- Stream changes via Serverpod streams for live "what just happened?" Admin tooling
- Export immutable archives to MinIO on a schedule with cryptographic chain hashes

## Out of scope

- **Analytical aggregation** → owned by `analytics` (different store, different consistency model)
- **Live ops alerts** → owned by `analytics` (anomaly detection)
- **Application-level logs** (HTTP errors, stack traces) → handled by GlitchTip + Loki

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `event.append(source, eventType, actor, subjectRefs, payload, idempotencyKey)` | Direct write (rare — most writes come via NATS subscription) |
| `event.query(filter, paging)` | Read with auth-scoped redaction |
| `event.get(eventId)` | Detail |
| `event.stream(filter)` | Serverpod stream for live tail |
| `export.run(range, idempotencyKey)` | Trigger archive export to MinIO |
| `accessLog.list(filter)` | Who queried what |

## Domain events

**Emits**:

- `AuditExportCreated`, `AuditExportVerified`

**Consumes**: all of them. This is the "must never lose an event" consumer.

## Cross-service calls

- **Synchronous**: none
- **Asynchronous**: subscribes to every `outbox.*` stream with durable consumers

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 5), §7 (outbox guarantees), §10 (cross-cutting disciplines)
