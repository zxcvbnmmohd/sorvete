# webhooks_server

> Outbound integrations. Merchants subscribe to events; we deliver them to the Merchant's own systems with retries, signing, and replay.

**Tier**: 5 (Platform & ops) · **Wave first activated**: 0 (stub) · **Wave deep**: 5 · **Database**: `webhooks` (Postgres)

## What this service owns

- **Subscription** — `(merchantId, url, eventPatterns[], secret, status)`
- **Delivery** — one attempt: `(subscriptionId, eventId, status, statusCode, responseBody, attempt)`
- **DeliveryQueue** — retry schedule with exponential backoff and dead-letter

## Responsibilities

- Let Merchants register URLs + event patterns via the Merchant app
- Subscribe to NATS broadly and filter per Subscription
- Sign each request with the Subscription's HMAC secret
- Retry on transient failure with exponential backoff; dead-letter after N attempts
- Expose delivery logs to the Merchant for debugging

## Out of scope

- **Inbound webhooks from third parties** → handled by the *consuming* service (e.g., `payments.webhooks.stripe`, `kyc.webhooks.sumsub`)
- **Real-time client subscriptions** → use Serverpod streams from each service directly

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `subscription.create(merchantId, url, eventPatterns[], idempotencyKey)` | Register |
| `subscription.list(merchantId)` | Manage |
| `subscription.update(id, patch, idempotencyKey)` | Edit |
| `subscription.rotateSecret(id, idempotencyKey)` | Issue new HMAC secret |
| `subscription.archive(id, idempotencyKey)` | Disable |
| `delivery.list(subscriptionId, filter)` | Logs |
| `delivery.replay(deliveryId, idempotencyKey)` | Manual replay |

## Domain events

**Emits**:

- `WebhookSubscribed`, `WebhookSubscriptionUpdated`, `WebhookSubscriptionArchived`
- `WebhookDelivered`, `WebhookDeliveryFailed`, `WebhookDeadLettered`

**Consumes**: any NATS subject the subscription pattern matches.

## Cross-service calls

- **Synchronous**: `merchant` (verify ownership)
- **Asynchronous**: emits to `audit`, `notifications` (Merchant alert on dead-letter)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §4 (Tier 5), §11 (Wave 5)
