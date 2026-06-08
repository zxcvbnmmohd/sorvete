# geo_server

> The map. Validates addresses, draws delivery-zone polygons, answers "do you deliver here?". The only service that talks to Nominatim and OpenRouteService.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 (validation) · 2 (routing/ETA) · **Database**: `geo` (Postgres + PostGIS extension)

## What this service owns

- **Address** — normalized, validated postal addresses with lat/lon
- **DeliveryZone** — a Merchant-Location-scoped PostGIS polygon (`(merchantId, locationId, polygon, isActive)`)
- **Geocoding cache** — to stay under the self-hosted Nominatim rate budget
- **Routing/ETA cache** — to stay under the OpenRouteService rate budget

## Responsibilities

- Geocode an address → lat/lon, normalize, cache
- Reverse-geocode a lat/lon → human address
- Check if a point is inside any active DeliveryZone for a Merchant Location
- (Wave 2+) Compute driving route + ETA between two points
- Centralize all calls to Nominatim / OpenRouteService so rate limits are managed in one place

## Out of scope

- **Driver dispatch** (which driver gets which order) → owned by `fulfillment`
- **Live driver tracking** → owned by `fulfillment` (uses `geo` only for ETA refresh)
- **Map tiles in the apps** → the apps consume free OSM tiles directly

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `address.validate(rawAddress)` | Normalize + geocode → `Address` |
| `address.reverseGeocode(lat, lon)` | lat/lon → best-guess Address |
| `zone.create(merchantId, locationId, polygon)` | Define a delivery polygon |
| `zone.update(zoneId, polygon, isActive)` | Edit / toggle |
| `zone.list(merchantId, locationId?)` | List zones |
| `zone.contains(merchantId, locationId, lat, lon)` | Boolean — is this point in any active zone? |
| `route.estimate(fromLat, fromLon, toLat, toLon)` | Wave 2+ — distance + ETA |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.geo.*`):

- `DeliveryZoneCreated`, `DeliveryZoneUpdated`, `DeliveryZoneArchived`

**Consumes**:

- `merchant.LocationCreated` — initialize a default empty zone
- `merchant.LocationArchived` — archive associated zones

## Cross-service calls

- **Synchronous**: `merchant` (verify Location ownership)
- **Asynchronous**: emits to `audit`

## Running locally

```sh
# Requires Postgres with the PostGIS extension enabled (the per-service Docker image handles this).
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §2 (Geocoding/Routing), §4 (Tier 0)
- `docs/adr/0003-service-catalog.md` — "geo is a service, not a library"
