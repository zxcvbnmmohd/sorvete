# kyc_server

> Identity verification. Provider-pluggable: Sumsub globally, Smile ID for African markets, manual queue for low-document countries.

**Tier**: 2 (Money & risk) · **Wave first activated**: 0 (stub) · **Wave active**: 3 · **Database**: `kyc` (Postgres)

## What this service owns

- **KycCase** — `(subjectType: merchant | driver, subjectId, providerId, status, expiresAt)`
- **Provider adapters** — `kyc_sumsub`, `kyc_smile`, `kyc_manual`
- **Document index** — references to `media` records, scoped to a private bucket
- **VerificationDecision** — `pending | approved | rejected | needs_review`

Strategy pattern: the right provider is chosen by the subject's country + Merchant vertical.

## Responsibilities

- Open a KycCase for a Merchant (before payouts) or a Driver (before onboarding)
- Drive the provider-specific verification flow (Sumsub iframe, Smile ID SDK, manual upload)
- Receive provider webhooks and translate into Sorvete-canonical decisions
- Block downstream actions (`payouts`, `fulfillment` onboarding) until status is `approved`
- Expire and re-verify on the Merchant's anniversary

## Out of scope

- **Image storage** → owned by `media` (this service holds *references*)
- **Risk scoring of transactions** → owned by `risk`
- **Sanctioned-market enforcement** (Syria, etc.) → handled at infrastructure boundary; see ADR-0004

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `case.open(subjectType, subjectId, country, idempotencyKey)` | Choose provider, return next step |
| `case.get(caseId)` | Status + checklist |
| `document.attach(caseId, fieldKey, mediaId)` | Reference an uploaded `media` |
| `case.submit(caseId, idempotencyKey)` | Hand off to provider |
| `case.decision(caseId, decision, reasons, idempotencyKey)` | Internal/admin override or manual queue outcome |
| `webhooks.sumsub(payload, signature)` | Sumsub callbacks |
| `webhooks.smile(payload, signature)` | Smile ID callbacks |

## Domain events

**Emits**:

- `KycCaseOpened`, `KycCaseSubmitted`, `KycApproved`, `KycRejected`, `KycExpiring`, `KycExpired`

**Consumes**:

- `merchant.MerchantCreated` — auto-open a Merchant case
- `fulfillment.DriverInvited` — auto-open a Driver case

## Cross-service calls

- **Synchronous**: `media` (verify document presence)
- **Asynchronous**: emits to `payouts` (unblock), `fulfillment` (unblock), `audit`, `notifications`, `support` (manual queue)

## Running locally

```sh
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

**Local env**: Sumsub / Smile ID adapters use sandbox creds — see `config/passwords.yaml`.

## References

- `ARCHITECTURE.md` §4 (Tier 2), §11 (Wave 3)
- `docs/adr/0003-service-catalog.md` — Strategy pattern per market
- `docs/adr/0004-cash-economy-from-day-one.md`
