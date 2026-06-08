# analytics_server

> The numbers. Projects every domain event into ClickHouse; serves Merchant and platform dashboards.

**Tier**: 5 (Platform & ops) · **Wave first activated**: 0 (stub) · **Wave deep**: 5 · **Database**: `analytics` (Postgres — projection metadata only; OLAP store is ClickHouse)

## What this service owns

- **Projection pipeline** — consumers that turn NATS events into ClickHouse rows
- **MerchantDashboard** — pre-aggregated rollups (orders / revenue / AOV / popular items)
- **PlatformDashboard** — internal cross-Merchant metrics
- **Query endpoint** — parameterized OLAP queries with auth-scoped row filtering
- **Cohort store** — for `marketing` segment refreshes

## Responsibilities

- Subscribe broadly to NATS; project events into ClickHouse with idempotent upserts
- Maintain materialized views for common dashboards
- Expose typed query endpoints for Merchant and Admin dashboards
- Refresh `marketing` segments on a schedule
- Emit `MetricThresholdCrossed` events for ops alerts (Wave 5+)

## Out of scope

- **Source-of-truth data** → still lives in the producing services
- **Audit log** → owned by `audit` (separate guarantee: append-only, compliance-grade)
- **Recommendations feedback** → owned by `recommendations`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `dashboard.merchant(merchantId, range)` | Pre-baked Merchant dashboard |
| `dashboard.platform(range)` | Admin view |
| `query.run(typedQueryId, params)` | Parameterized query |
| `cohort.refresh(segmentId)` | For `marketing` |
| `report.export(query, format)` | CSV / Parquet export to MinIO |

## Domain events

**Emits**:

- `MetricThresholdCrossed` (Wave 5+ — anomaly detection alerts)

**Consumes**: all of them. This is the broadest consumer in the platform.

## Cross-service calls

- **Synchronous**: none (this service is asked, never asks)
- **Asynchronous**: subscribes to every `outbox.*` stream

## Running locally

```sh
# Requires ClickHouse running. See root docker-compose.yml.
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.
**External**: ClickHouse on `:8123` (HTTP) / `:9000` (native) by convention.

## References

- `ARCHITECTURE.md` §2 (ClickHouse), §4 (Tier 5), §11 (Wave 5)
