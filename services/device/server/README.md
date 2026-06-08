# device_server

> The IT department. Pairs physical iPads, terminals, and displays to specific Merchant Locations so a POS or KDS device is always bound to the business it serves.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 · **Database**: `device` (Postgres)

## What this service owns

- **Device** — a registered physical unit (POS Terminal or KDS Display)
- **Pairing** — the binding between a Device, a Merchant, and a Location
- **Pairing Code** — short-lived secret used to bootstrap a Pairing

A Device is identified independently of any User. Staff sign-in on the device is layered on top via `identity`.

## Responsibilities

- Issue short-lived pairing codes (and QR payloads) from the Merchant app
- Consume a code from a POS/KDS app, register the device, mint a long-lived device token
- Maintain the (Device → Merchant → Location) registry queried by `ordering`, `kitchen`, `payments`
- Revoke devices (lost / stolen / decommissioned) and rotate device tokens
- Enforce per-device kind: a Location can have many POS Terminals + many KDS Displays, but a Device has exactly one kind

## Out of scope

- **Staff authentication on a paired device** → `identity` (Staff still sign in on top)
- **Device-level hardware diagnostics / telemetry** → out of scope for v1; revisit in Wave 5
- **Push-notification routing tokens** → owned by `notifications`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `pairing.requestCode(merchantId, locationId, deviceKind)` | Issue a short-lived 6-char code |
| `pairing.complete(code)` | Consume code → return device token + (merchantId, locationId) |
| `device.list(merchantId)` | List all paired devices for a Merchant |
| `device.revoke(deviceId)` | Invalidate device token |
| `device.rotateToken(deviceId)` | Issue a new device token, keep pairing |
| `device.resolve(deviceToken)` | Internal: device-token → (merchantId, locationId, kind) |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.device.*`):

- `DevicePaired`, `DeviceRevoked`, `DeviceTokenRotated`

**Consumes**:

- `merchant.LocationArchived` — auto-revoke all devices at the archived Location

## Cross-service calls

- **Synchronous**: `merchant` (verify Location belongs to Merchant when pairing)
- **Asynchronous**: emits to `audit`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 0)
- `docs/adr/0003-service-catalog.md`
- `CONTEXT.md` — _POS Terminal, KDS Display, Device Pairing_
