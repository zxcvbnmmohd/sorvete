# recommendations_server

> Personalization. "Order it again", "you might like", "nearby trending". Learns from impressions, clicks, conversions, dismissals.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `recommendations` (Postgres)

## What this service owns

- **Customer profile features** — engagement signals (frequency, recency, cuisine affinity)
- **Recommendation slots** — surface contracts (`home_hero`, `restock_card`, `merchant_detail_more`)
- **Feedback ledger** — impressions, clicks, conversions, dismissals — the training input
- **Cold-start fallbacks** — what to show when there's no history

Per ADR-0003: this service owns its **own feedback-loop state**, not a read-only projection of `analytics`.

## Responsibilities

- Serve slot-keyed recommendations for a Customer + context
- Record impressions and outcomes (clicks → conversions or dismissals)
- Maintain Customer-affinity features incrementally
- Provide A/B-testable strategies behind the same slot contract
- Respect dismissals ("not interested in X for the next N days")

## Out of scope

- **Search query results** → owned by `search`
- **Ad-driven placement** → owned by `ads` (separate slot; honesty in surface labelling)
- **Customer profile / loyalty** → owned by `loyalty` and (eventually) a CRM service

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `recs.forSlot(customerId, slot, context)` | Slot-keyed list |
| `feedback.impression(customerId, slot, itemRefs, idempotencyKey)` | Bulk impression event |
| `feedback.click(customerId, slot, itemRef, idempotencyKey)` | Click |
| `feedback.convert(customerId, slot, itemRef, orderId, idempotencyKey)` | Reached purchase |
| `feedback.dismiss(customerId, slot, itemRef, reason, idempotencyKey)` | Not interested |

## Domain events

**Emits**:

- `RecommendationServed`, `RecommendationClicked`, `RecommendationConverted`, `RecommendationDismissed`

**Consumes**:

- `ordering.OrderCompleted` — strong positive signal (auto-convert)
- `reviews.ReviewPosted` — engagement signal
- `catalog.ProductArchived` — drop from candidate sets

## Cross-service calls

- **Synchronous**: `catalog` (resolve item references for the response)
- **Asynchronous**: emits to `audit`, `analytics`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 4), §11 (Wave 4)
- `docs/adr/0003-service-catalog.md` — "owns its own feedback-loop state"
