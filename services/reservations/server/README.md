# reservations_server

> Table booking and appointment scheduling. For dine-in restaurants, salons, and any vertical that pre-allocates time slots.

**Tier**: 3 (Fulfillment) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `reservations` (Postgres)

## What this service owns

- **Resource** — a bookable thing at a Location: a table, a chair, a treatment room
- **Schedule** — a Resource's availability template (hours, blackouts, capacity)
- **Reservation** — `(customerId, resourceId, startsAt, endsAt, state)`
- **Waitlist** — overflow when a desired slot is full

## Responsibilities

- Define Resources and Schedules per Location
- Quote available slots for a `(locationId, partySize, dateRange)` query
- Book / modify / cancel a Reservation
- Send confirmations + reminders via `notifications`
- Link a Reservation to an Order at check-in (the actual table service)

## Out of scope

- **Order taking on the day** → owned by `ordering`
- **Walk-in customer flow without a reservation** → not in this service
- **Payment for the reservation deposit** → handled via `payments`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `resource.upsert(merchantId, locationId, ...)` | Define a table / room |
| `schedule.set(resourceId, template)` | Hours / capacity |
| `slot.search(locationId, partySize, dateRange)` | Available slots |
| `reservation.book(customerId, resourceId, slot, idempotencyKey)` | Reserve |
| `reservation.modify(id, patch, idempotencyKey)` | Reschedule / resize |
| `reservation.cancel(id, reason, idempotencyKey)` | Cancel |
| `reservation.checkIn(id, idempotencyKey)` | Mark as arrived |
| `reservation.linkOrder(reservationId, orderId)` | Bind to a service Order |

## Domain events

**Emits**:

- `ReservationBooked`, `ReservationModified`, `ReservationCancelled`, `ReservationCheckedIn`, `ReservationNoShow`

**Consumes**:

- `merchant.LocationArchived` — cascade-cancel future reservations

## Cross-service calls

- **Synchronous**: `merchant` (Location ownership), `payments` (deposit, optional)
- **Asynchronous**: emits to `notifications` (reminders), `audit`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 3), §11 (Wave 4)
