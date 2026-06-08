# kitchen_server

> The KDS. Turns Orders into kitchen Tickets, tracks prep state, bumps when done.

**Tier**: 3 (Fulfillment) · **Wave first activated**: 0 (consumer) · **Wave deep**: 1 (interactive KDS app) · **Database**: `kitchen` (Postgres)

## What this service owns

- **Ticket** — KDS-side representation of an Order (or the prep-bearing subset of its OrderLines)
- **TicketState** — `received → cooking → ready → bumped`
- **Station** — optional sub-routing within a Location's kitchen (grill / fryer / cold)
- **BumpTime** — historical "how long did this take?" data, surfaced as Merchant analytics

Tickets only exist for Locations whose `fulfillment_profile` includes kitchen work (`kitchen_prep` or `mixed`). Pure `pick_from_shelf` Locations never generate Tickets.

## Responsibilities

- Listen for `ordering.OrderPlaced` and create a Ticket at the right Location's kitchen
- Filter / route OrderLines: only `requires_preparation: true` Variants become Ticket lines
- Drive the Ticket state machine via the KDS app (bump, recall, prioritize)
- Push live updates to the KDS app via Serverpod streams
- Emit `TicketBumped` so `ordering` knows when an OrderLine is ready

## Out of scope

- **Order lifecycle** → owned by `ordering`
- **Driver dispatch** → owned by `fulfillment` (which listens for `TicketBumped` indirectly via `ordering.OrderReady`)
- **Bagging / shelf-pick workflow** → not a v1 service; covered by `ordering` on `pick_from_shelf` Locations

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `ticket.list(locationId, state?)` | KDS app inbox |
| `ticket.get(ticketId)` | Detail |
| `ticket.markCooking(ticketId, deviceToken, idempotencyKey)` | Started |
| `ticket.bump(ticketId, deviceToken, idempotencyKey)` | Mark ready |
| `ticket.recall(ticketId, reason, idempotencyKey)` | Un-bump (oops) |
| `ticket.stream(locationId)` | Serverpod live stream of ticket changes |

All mutating endpoints require an `idempotencyKey` and a valid device token (KDS Display).

## Domain events

**Emits**:

- `TicketCreated`, `TicketCooking`, `TicketBumped`, `TicketRecalled`

**Consumes**:

- `ordering.OrderPlaced` — create Ticket (if applicable)
- `ordering.OrderCancelled` — auto-recall Ticket

## Cross-service calls

- **Synchronous**: `device` (validate KDS Display), `merchant` (Location fulfillment_profile)
- **Asynchronous**: emits to `ordering` (so OrderLine state transitions), `audit`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 3), §6 (happy path), §11 (Wave 1)
- `CONTEXT.md` — _Ticket, Fulfillment Profile, requires_preparation_
