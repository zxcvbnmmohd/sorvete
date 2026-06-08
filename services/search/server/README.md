# search_server

> Customer-facing search. Type "burger" — get nearby Merchants + Products. Backed by Meilisearch.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (stub) · **Wave deep**: 2 · **Database**: `search` (Postgres for projection metadata; main index in Meilisearch)

## What this service owns

- **SearchIndex** — Meilisearch indices for `products`, `merchants`, `locations`
- **Indexing pipeline** — consumes domain events and projects them into Meilisearch
- **Ranking config** — per-vertical ranking rules, synonyms, stopwords, typo tolerance
- **Suggestions** — query-completion data

## Responsibilities

- Subscribe to `catalog`, `merchant`, `geo` events and keep Meilisearch in sync
- Serve `/search` queries with locale + location filters
- Provide typeahead suggestions
- Re-rank results based on Customer location proximity (uses `geo`)
- Boost ad-promoted results from `ads` (Wave 4)

## Out of scope

- **The Meilisearch instance itself** → infra (docker compose at root)
- **Domain truth** → this is a projection — `catalog` and `merchant` remain the source of truth
- **Recommendations / personalization** → owned by `recommendations`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `search.products(q, locationId?, filters?, paging)` | Product search |
| `search.merchants(q, lat?, lon?, filters?, paging)` | Merchant search |
| `search.suggest(q, kind)` | Typeahead |
| `index.reindex(scope)` | Admin: rebuild index from source-of-truth |

## Domain events

**Emits**: minimal — `IndexRebuildRequested`, `IndexRebuildCompleted` (operational)

**Consumes**:

- `catalog.ProductCreated`, `ProductUpdated`, `ProductArchived`, `VariantUpdated`
- `merchant.MerchantCreated`, `MerchantUpdated`, `LocationCreated`, `LocationUpdated`, `LocationArchived`
- `geo.DeliveryZoneUpdated` — affects search-by-deliverable

## Cross-service calls

- **Synchronous**: `geo` (compute proximity for ranking)
- **Asynchronous**: emits to `audit`

## Running locally

```sh
# Requires Meilisearch running. See root docker-compose.yml.
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.
**External**: Meilisearch on `:7700` by convention.

## References

- `ARCHITECTURE.md` §2 (Search), §4 (Tier 4), §11 (Wave 2)
