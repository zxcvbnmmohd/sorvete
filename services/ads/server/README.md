# ads_server

> Sponsored listings. Merchants bid for placement in search and home-feed slots. We run the auction and bill them.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (stub) · **Wave deep**: 4 · **Database**: `ads` (Postgres)

## What this service owns

- **Campaign** — Merchant's ad budget, bid, target audience, schedule
- **AdSlot** — surface contract (`search_top`, `home_carousel`, `category_top`)
- **Bid** — per-slot bidding strategy (CPM / CPC)
- **Impression / Click** — billable events
- **Wallet (advertising)** — prepaid balance that drains as ads serve

## Responsibilities

- CRUD campaigns via the Merchant app
- Hold the auction: for a given slot + viewer context, pick the winning Campaign
- Record impressions and clicks; debit the Merchant's prepaid ads Wallet
- Pause Campaigns when budget is exhausted or pacing limits hit
- Emit billing data to `payouts` / `wallet`

## Out of scope

- **Organic ranking** → owned by `search` (it consumes our `selectedForSlot` call)
- **Recommendations** → owned by `recommendations` (separate slot)
- **Payment to fund the ads Wallet** → owned by `payments`

## Endpoints (expected)

| Endpoint                                                                        | Purpose                                 |
| ------------------------------------------------------------------------------- | --------------------------------------- |
| `campaign.create(merchantId, bid, budget, schedule, targeting, idempotencyKey)` | Create                                  |
| `campaign.update(id, patch, idempotencyKey)`                                    | Edit                                    |
| `campaign.pause(id, idempotencyKey)` · `campaign.resume(id, idempotencyKey)`    | Manual pacing                           |
| `auction.select(slot, viewerContext)`                                           | Internal — called by `search` / clients |
| `event.impression(campaignId, slot, viewerContext, idempotencyKey)`             | Bill impression                         |
| `event.click(campaignId, slot, viewerContext, idempotencyKey)`                  | Bill click                              |
| `wallet.topUp(merchantId, paymentIntentId)`                                     | Fund ads Wallet                         |

## Domain events

**Emits**:

- `CampaignCreated`, `CampaignPaused`, `CampaignResumed`, `CampaignDepleted`
- `AdImpressionRecorded`, `AdClickRecorded`

**Consumes**:

- `payments.PaymentCaptured` (ads-funding intent) — credit ads Wallet

## Cross-service calls

- **Synchronous**: `wallet` (debit), `merchant` (Merchant info), called by `search`
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
