# fulfillment_server

> The dispatcher. Picks a Driver for a ready Order, computes ETA, tracks the route, handles the handoff.

**Tier**: 3 (Fulfillment) · **Wave first activated**: 0 (stub) · **Wave deep**: 2 · **Database**: `fulfillment` (Postgres)

## What this service owns

- **DriverProfile** — `(userId, status: offline | available | on_trip, vehicle, currentLocation, cashFloatCap)`
- **Dispatch** — the matchmaker between a ready Order and a Driver
- **Trip** — the end-to-end record of a Driver delivering an Order (assignment, pickup, dropoff, OTP verification)
- **DropOff** — confirmation event with optional signature / photo

## Responsibilities

- Maintain the live Driver pool with location updates (consumed from the Driver app)
- React to `ordering.OrderReady` (for delivery orders) — pick a Driver, send the offer
- Drive the Trip state machine (`offered → accepted → en_route_to_pickup → picked_up → en_route_to_dropoff → delivered | failed`)
- Coordinate `cash_on_delivery` OTP verification at dropoff
- Refresh ETAs via `geo.route.estimate` and push them to the Customer app

## Out of scope

- **Address validation / route compute** → owned by `geo` (this service consumes `geo.route.estimate`)
- **Driver payouts** → owned by `payouts`
- **Driver KYC** → owned by `kyc`
- **Cash collected** → owned by `wallet` (CashFloat is a Wallet account)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `driver.onboard(userId, vehicle, idempotencyKey)` | Create DriverProfile |
| `driver.setStatus(driverId, status, location?)` | Online / offline / on-trip |
| `driver.updateLocation(driverId, lat, lon)` | Live position |
| `trip.offer(orderId, driverId, idempotencyKey)` | Internal: send the offer |
| `trip.accept(tripId, driverId, idempotencyKey)` | Driver accepts |
| `trip.markPickedUp(tripId, idempotencyKey)` | Driver picked up |
| `trip.markDelivered(tripId, otp?, signature?, idempotencyKey)` | Final |
| `trip.cancel(tripId, reason, idempotencyKey)` | Failure cases |
| `trip.streamForOrder(orderId)` | Customer live tracking |

## Domain events

**Emits**:

- `DriverOnboarded`, `DriverStatusChanged`
- `TripOffered`, `TripAccepted`, `TripPickedUp`, `TripDelivered`, `TripCancelled`

**Consumes**:

- `ordering.OrderReady` — kick off dispatch (delivery only)
- `kyc.KycApproved` (Driver) — unblock onboarding
- `wallet.CashFloatRemitted` — keep Driver available after capped float is cleared

## Cross-service calls

- **Synchronous**: `geo` (route/ETA), `wallet` (CashFloat status), `ordering` (mark delivered)
- **Asynchronous**: emits to `notifications`, `audit`, `analytics`, `risk`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 3), §11 (Wave 2)
- `CONTEXT.md` — _Driver, Cash Float, Order Completion Code (OTP)_
