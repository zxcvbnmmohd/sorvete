# catalog_server

> The menu / aisle. Owns every sellable thing across every Merchant. The source of truth for what's on offer — but not how much stock there is and not what to charge.

**Tier**: 1 (Commerce core) · **Wave first activated**: 0 · **Database**: `catalog` (Postgres)

## What this service owns

- **Product** — a sellable thing (`requires_preparation`, `prep_time_estimate`, vertical-neutral shape)
- **Variant** — a purchasable size/option of a Product (pricing lives on the Variant)
- **Modifier** & **Modifier Group** — add-ons / substitutions
- **Category** — taxonomy for browsing
- **CatalogPublication** — Location-scoped activation (a Product can be Catalog-defined but Location-disabled)

## Responsibilities

- CRUD Products / Variants / Modifiers / Categories (Merchant-scoped)
- Resolve Catalog for a given `(merchantId, locationId)` for the Customer/POS apps
- Publish/unpublish a Product at a Location
- Emit events for downstream projections (`search`, `inventory`, `recommendations`, `media`)

## Out of scope

- **Stock levels per Location** → owned by `inventory`
- **Tax, surge, fee math** → owned by `pricing` (Variant carries list price; `pricing` computes the rest)
- **Photos** → only references to `media`; actual blobs live in `media`
- **Search ranking & query** → owned by `search`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `product.create(merchantId, ...)` | Create Product with at least one Variant |
| `product.update(id, patch)` | Edit Product |
| `product.archive(id)` | Soft-delete |
| `variant.add(productId, ...)` | Add a Variant |
| `variant.update(id, patch)` | Edit Variant (incl. list price) |
| `modifier.attach(productId, modifierGroupId)` | Attach a Modifier Group |
| `category.upsert(merchantId, ...)` | CRUD Category |
| `catalog.forLocation(merchantId, locationId)` | Customer-facing view |
| `publication.set(productId, locationId, isActive)` | Enable/disable a Product at a Location |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.catalog.*`):

- `ProductCreated`, `ProductUpdated`, `ProductArchived`
- `VariantAdded`, `VariantUpdated`, `VariantArchived`
- `ModifierGroupChanged`
- `CatalogPublicationChanged`

**Consumes**:

- `merchant.LocationArchived` — cascade-archive Location publications

## Cross-service calls

- **Synchronous**: `merchant` (verify Merchant ownership), `media` (reference check)
- **Asynchronous**: emits to `search`, `inventory`, `recommendations`, `audit`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 1)
- `CONTEXT.md` — _Product, Variant, Modifier, Catalog, Vertical_
