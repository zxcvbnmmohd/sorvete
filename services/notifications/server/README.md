# notifications_server

> Transactional messaging. Receipts, order updates, KYC reminders, payout alerts. Wraps Postal / Twilio / FCM / APNs / WhatsApp.

**Tier**: 4 (Engagement) · **Wave first activated**: 0 (email) · later waves add transports · **Database**: `notifications` (Postgres)

## What this service owns

- **Adapters** — `postal_email`, `twilio_sms`, `twilio_whatsapp`, `fcm_push`, `apns_push`
- **Template** — channel-typed message templates with variable bindings + i18n via `slang`
- **Notification** — `(userId, channel, template, payload, state)` — one outbound message
- **DeliveryReceipt** — provider-side outcome (delivered / bounced / failed)
- **DeviceToken** — per-User push tokens

## Responsibilities

- Render template + locale + payload → channel-specific message
- Pick the best channel for a given purpose given the User's preferences and reachability
- Dispatch via the right adapter; retry on transient failure
- Reconcile provider webhooks into `DeliveryReceipt`
- Maintain push-notification device tokens (separate from `device` paired hardware)

## Out of scope

- **Bulk / marketing sends** → owned by `marketing` (which hands work to us)
- **Consent and segmentation** → owned by `marketing`
- **Receipt PDF generation** → done client-side (we just attach the produced bytes)

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `send.transactional(userId, templateKey, payload, channelHint?, idempotencyKey)` | One-off send |
| `send.queueBulk(messages[], idempotencyKey)` | Called by `marketing` |
| `template.upsert(key, channel, locale, body)` | Manage templates |
| `device.registerToken(userId, platform, token)` | Push registration |
| `device.revokeToken(userId, token)` | Remove |
| `webhooks.twilio(payload, signature)` · `webhooks.postal(...)` · `webhooks.fcm(...)` | Provider callbacks |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits**:

- `NotificationQueued`, `NotificationDelivered`, `NotificationFailed`, `NotificationBounced`
- `DeviceTokenRegistered`, `DeviceTokenRevoked`

**Consumes**:

- `ordering.OrderPlaced` / `OrderAccepted` / `OrderReady` / `OrderCompleted` / `OrderCancelled` → templated receipts/updates
- `payments.PaymentFailed` → "your payment failed" alert
- `kyc.KycRejected` → user-facing nudge
- `payouts.PayoutCompleted` → Merchant alert

## Cross-service calls

- **Synchronous**: `merchant`, `identity` (resolve recipient channels) — read-only
- **Asynchronous**: emits to `audit`, `analytics`, `marketing` (engagement)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

**Local env**: Postal / Twilio / FCM / APNs creds live in `config/passwords.yaml`. Email is the only Wave 0 transport — other adapters use stubs locally.

## References

- `ARCHITECTURE.md` §2 (paid integrations), §4 (Tier 4)
- `docs/adr/0003-service-catalog.md`
