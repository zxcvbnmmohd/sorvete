# Database-per-service

## Context

ADR-0001 commits to true microservices. Two data-ownership strategies remained for grilling: schema-per-service inside one shared Postgres cluster, or one Postgres database per service (each in its own container).

## Decision

**One Postgres database per service.** Each service's container connects only to its own database via its own credentials. No service holds credentials for, or has network access to, any database other than its own.

## Why

Schema-per-service in one shared Postgres does not prevent cross-schema joins — they are a single SQL keystroke away — and the discipline required to avoid them is not enforceable by code review at this codebase's eventual size. Separate databases make a join across services structurally impossible: the connection itself cannot reach the other service's data. Per-service backups, point-in-time recovery, encryption-at-rest keys, role/credential rotation, and migration cadence all become independent.

## Consequences

- Postgres container count scales with service count. On Dokploy, this is incremental storage cost only — all instances share the `postgres:16-alpine` image and run in the same VPS until horizontal scale demands a split.
- Cross-service reads always go through the owner service's API or its event stream. Foreign data is denormalized into the consuming service's local read model and refreshed via events.
- Backups are orchestrated centrally (one cron job, N `pg_dump`s, one offsite storage destination). Restore drills are per-service.
- Some operational data (e.g. a Customer's display name shown on an Order) intentionally exists in multiple services as denormalized projections. This is acceptable and expected; the owner service is always the source of truth.

## Status

accepted
