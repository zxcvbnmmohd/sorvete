# support_server

> Customer Service tickets. The escalation queue when something needs a human — disputes that miss windows, manual KYC, hard-to-reach Customers, refund judgment calls.

**Tier**: 5 (Platform & ops) · **Wave first activated**: 0 (stub) · **Wave deep**: 5 · **Database**: `support` (Postgres)

## What this service owns

- **Ticket** — `(subjectType, subjectId, openedBy, assignedAgent?, priority, status)`
- **Message** — back-and-forth thread (Customer / Merchant / Agent / system)
- **Macros** — agent-side templated replies
- **Routing rule** — which agent / queue picks up a Ticket
- **SlaPolicy** — response / resolution time targets

## Responsibilities

- Accept Tickets from Customers, Merchants, and other services (auto-escalation)
- Route Tickets to the right queue (refunds, disputes, KYC, fraud, general)
- Drive Ticket state (`open → assigned → waiting_customer → resolved → closed`)
- Track SLA compliance and emit alerts when targets are missed
- Hand off context: every Ticket can read the relevant audit trail, order detail, dispute, KYC case

## Out of scope

- **Marketing-style mass outreach** → owned by `marketing`
- **Internal incident response (engineering)** → outside Sorvete; uses external paging
- **Actually issuing the refund / KYC override** → support agents *call* the right service (`payments.refund.issue`, `kyc.case.decision`); we don't own those mutations

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `ticket.create(subjectType, subjectId, openedBy, summary, priority, idempotencyKey)` | Open |
| `ticket.list(filter, paging)` | Agent inbox / Customer view |
| `ticket.get(ticketId)` | Detail + thread + linked context |
| `ticket.assign(id, agentId, idempotencyKey)` | Pick up |
| `ticket.message(id, body, mediaIds?, idempotencyKey)` | Reply |
| `ticket.setStatus(id, status, idempotencyKey)` | Workflow |
| `macro.list()` · `macro.upsert(...)` | Agent productivity |

## Domain events

**Emits**:

- `TicketOpened`, `TicketAssigned`, `TicketMessageAdded`, `TicketResolved`, `TicketClosed`
- `TicketSlaBreached`

**Consumes**:

- `disputes.DisputeExpired` — auto-open Ticket
- `kyc.KycRejected` + flagged-manual-review — auto-open Ticket
- `risk.RiskHoldPlaced` (above threshold) — auto-open Ticket
- `reviews.ReviewHidden` (Merchant appeal) — auto-open

## Cross-service calls

- **Synchronous**: `audit` (pull context), `merchant` / `ordering` / `disputes` / `kyc` (read context for the Ticket detail view)
- **Asynchronous**: emits to `audit`, `notifications` (alert agents / customers)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 5), §11 (Wave 5)
