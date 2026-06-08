# reviews_server

> Stars and comments. Customers rate, Merchants reply, abuse gets flagged.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `reviews` (Postgres)

## What this service owns

- **Review** — `(orderId, customerId, merchantId, rating, body, mediaIds[], state)`
- **Reply** — Merchant's response (one per Review)
- **Report** — Customer / Merchant flagging a Review for moderation
- **Aggregate** — denormalized `(merchantId, avgRating, count)` for fast Merchant cards

## Responsibilities

- Allow a Customer to post a Review only after `OrderCompleted` (verified-purchase guarantee)
- Allow the Merchant to post one Reply
- Handle abuse: report → moderation queue → hide / restore / ban
- Maintain Merchant aggregates and emit `MerchantRatingChanged` so `search` reranks

## Out of scope

- **Marketing campaigns to request reviews** → owned by `marketing`
- **Merchant-quality scoring (internal)** → owned by `analytics`
- **Driver / Customer rating** → out of v1 scope

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `review.post(orderId, rating, body, mediaIds?, idempotencyKey)` | Customer posts |
| `review.list(merchantId, paging)` | Merchant detail page |
| `review.get(reviewId)` | Detail |
| `reply.post(reviewId, body, idempotencyKey)` | Merchant replies |
| `report.create(reviewId, reason, idempotencyKey)` | Flag for moderation |
| `moderation.decide(reviewId, action)` | Admin |

## Domain events

**Emits**:

- `ReviewPosted`, `ReviewHidden`, `ReviewRestored`
- `ReplyPosted`
- `MerchantRatingChanged`

**Consumes**:

- `ordering.OrderCompleted` — unlock review eligibility for that Order
- `ordering.OrderRefunded` — flag eligibility window

## Cross-service calls

- **Synchronous**: `ordering` (verify Order exists & completed), `media` (validate mediaIds)
- **Asynchronous**: emits to `search` (rerank), `recommendations`, `audit`, `notifications`, `support`

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 4), §11 (Wave 4)
