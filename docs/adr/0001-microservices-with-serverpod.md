# Microservices with Serverpod (one project per bounded context)

## Context

Sorvete is a hybrid marketplace + SaaS commerce platform targeting production parity with Uber Eats + Square from day 1 of public launch. Three architectural shapes were considered:

- **(a) Modular monolith** — one Serverpod backend, one Postgres, bounded contexts as packages
- **(b) Modulith with schema-per-context** — one Postgres, one Serverpod, contexts isolated via Postgres schemas
- **(c) True microservices** — one Serverpod project per bounded context, one Postgres database per context

## Decision

**(c) True microservices.** Each bounded context is its own Serverpod project under `services/`. Each owns its own Postgres database. Cross-context communication is either synchronous (Serverpod-generated typed clients over HTTP) or asynchronous (events on NATS JetStream with an outbox pattern in each service). There are no distributed transactions; cross-context flows are sagas.

## Why

Boundary discipline is the load-bearing property of this system. With 32 bounded contexts of varying compliance scope (Payments has PCI, Audit has SOC2 retention, KYC has biometric-data law exposure), scaling profile (Search runs on Meilisearch, Analytics on ClickHouse, Wallet is a double-entry ledger), and ownership cadence, keeping them as schemas inside one database lets the boundary erode silently as the codebase grows — a SQL keystroke can cross any context. Separate services + separate databases make the cost of crossing a boundary visible and physically enforced. The system *cannot* drift into a distributed monolith by accident.

This decision is acknowledged to fight Serverpod's monolith-shaped defaults (single endpoint registry, single auth, single generated client). That cost is paid up-front in scaffolding discipline, not in day-to-day feature work.

## Consequences

- Every cross-context read is a network call or a local read-model projection backed by an event consumer.
- Every multi-context state transition is a saga (Order placement spans Ordering → Pricing → Inventory → Payments → Notifications).
- The monorepo holds N × 3 packages from Serverpod's scaffold (`server` + `client` + `flutter` per service). At parity (32 services) the workspace lists ~100 Serverpod-generated packages plus shared packages.
- Local development requires Docker Compose with all dependent services running for E2E flows; per-service tests run in isolation against their own database.
- Schema migrations are per-service and independent; cross-service API contract changes follow the expand/contract pattern.

## Status

accepted
