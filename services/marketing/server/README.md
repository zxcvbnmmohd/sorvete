# marketing_server

> Bulk outreach. Email / SMS / WhatsApp campaigns to Customer segments. Different SLAs and consent rules from transactional `notifications`.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `marketing` (Postgres)

## What this service owns

- **Segment** — saved query describing a Customer cohort (rules-based, refreshable)
- **Campaign** — `(channels[], segmentId, content, schedule, controls)` (rate limit, throttle, A/B)
- **Send** — record of one Customer × Campaign send (`queued | sent | delivered | bounced | opened | clicked | unsubscribed`)
- **ConsentLog** — opt-in / opt-out per channel per Customer

## Responsibilities

- Build / refresh Segments from `analytics` projections
- Schedule and throttle Campaign sends across channels
- Respect consent and per-Customer marketing-frequency caps
- Push individual messages to `notifications` for actual delivery (shares adapters but not state)
- Track engagement (opens, clicks) and emit them to `analytics`

## Out of scope

- **Transactional messaging** (receipts, order updates) → owned by `notifications`
- **The send adapters themselves** (Twilio / Postal / FCM / WhatsApp) → owned by `notifications` (we hand off messages to it)
- **Promotion definitions** → owned by `promotions` (Campaign may *reference* a promo)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `segment.upsert(merchantId, rules)` | Define a segment |
| `segment.preview(segmentId)` | Estimated size + sample |
| `campaign.create(merchantId, channels, segmentId, content, schedule, idempotencyKey)` | Define a campaign |
| `campaign.send(id, idempotencyKey)` | Trigger send |
| `campaign.pause(id, idempotencyKey)` · `resume(id, idempotencyKey)` | Pacing |
| `send.list(campaignId, filter)` | Engagement view |
| `consent.set(customerId, channel, optIn, source)` | Update consent |
| `webhooks.engagement(provider, payload)` | Open / click / bounce ingestion |

## Domain events

**Emits**:

- `SegmentRefreshed`, `CampaignCreated`, `CampaignScheduled`, `CampaignSent`, `CampaignPaused`
- `MessageQueued` (handed off to `notifications`), `MessageDelivered`, `MessageOpened`, `MessageClicked`, `MessageBounced`
- `ConsentChanged`

**Consumes**:

- `identity.UserCreated` — seed default consent
- `ordering.OrderCompleted` — drive lifecycle campaigns
- `notifications.NotificationDelivered` / `Failed` — backfill send state

## Cross-service calls

- **Synchronous**: `notifications` (push individual messages), `analytics` (segment refresh queries)
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
- `docs/adr/0003-service-catalog.md` — "marketing + notifications merge rejected"
