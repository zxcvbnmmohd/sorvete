# merchant_server

> The HR & ops record. Who the business is, where it operates, and who's allowed to act on its behalf.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 · **Database**: `merchant` (Postgres)

## What this service owns

- **Merchant** — the business entity that signed up to Sorvete (one or more Locations + a Catalog ownership pointer)
- **Location** — a physical site of a Merchant (the unit at which fulfillment happens and devices are paired)
- **Staff** — a User authorized to act on behalf of a specific Merchant, with a role (Owner / Manager / Cashier / Server / …)
- **Settings** — Merchant-level configuration: branding, timezone, currency, vertical, `fulfillment_profile`

## Responsibilities

- Onboard a Merchant and its first Location
- Add / archive Locations, edit hours, addresses (delegating address validation to `geo`)
- Invite, accept, revoke Staff memberships with role-based permissions
- Expose authoritative `(merchantId, locationId)` to every other service
- Hold the per-Merchant `vertical` flag that drives UI gating across the apps

## Out of scope

- **Authentication / passwords** → owned by `identity`
- **KYC documents** → owned by `kyc`
- **Catalog** → owned by `catalog` (only owns the *pointer*, not the products)
- **Inventory levels** → owned by `inventory`
- **Bank accounts / payout schedules** → owned by `payouts`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `merchant.create(name, vertical, country, currency)` | Onboard a new Merchant + initial Location |
| `merchant.update(id, patch)` | Edit settings |
| `location.add(merchantId, address, fulfillmentProfile)` | Add a Location |
| `location.list(merchantId)` | List all Locations for a Merchant |
| `location.update(id, patch)` | Edit hours, address, profile |
| `location.archive(id)` | Soft-delete |
| `staff.invite(merchantId, email, role)` | Send invitation |
| `staff.accept(invitationToken)` | Accept (binds inviting User to the Merchant) |
| `staff.list(merchantId)` | List Staff for a Merchant |
| `staff.revoke(staffId)` | Remove access |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.merchant.*`):

- `MerchantCreated`, `MerchantUpdated`, `MerchantArchived`
- `LocationCreated`, `LocationUpdated`, `LocationArchived`
- `StaffInvited`, `StaffJoined`, `StaffRevoked`

**Consumes**:

- `identity.UserCreated` — pre-create Staff record when the inviting email signs up

## Cross-service calls

- **Synchronous**: `geo` (address validation when adding a Location), `identity` (resolve invited email → User)
- **Asynchronous**: emits to nearly every downstream service — `catalog`, `inventory`, `ordering`, `payouts`, `notifications`, `audit`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 0)
- `docs/adr/0003-service-catalog.md` (Tier 0 — Foundation)
- `CONTEXT.md` — _Merchant, Location, Staff, Vertical, Fulfillment Profile_
