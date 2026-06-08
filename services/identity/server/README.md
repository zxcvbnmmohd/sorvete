# identity_server

> The bouncer. Every request that touches Sorvete starts here — user accounts, credentials, sessions, and JWT issuance.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 · **Database**: `identity` (Postgres)

## What this service owns

The canonical record of every **User** on the platform. A User is platform-scoped and role-neutral — the same User row backs a Customer browsing the marketplace, a Staff member at one or more Merchants, and a Driver delivering orders.

This service is the **only** source of authentication. No other service stores passwords, OAuth tokens, or session state.

## Responsibilities

- Sign-up / sign-in via email + password (`serverpod_auth_idp` package)
- JWT access-token issuance and refresh
- Session lifecycle (revoke, list active devices)
- Password reset, email verification
- Audit-logging every credential event (delegated to `audit` via outbox)

## Out of scope

- **Merchant-scoped Staff membership** → owned by `merchant` (Staff is a User with a role at a specific Merchant)
- **KYC / identity-document verification** → owned by `kyc`
- **Marketing consent + preferences** → owned by `marketing`
- **Customer profile (loyalty, order history, addresses)** → owned by the relevant domain services

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `emailIdp.signUp(email, password)` | Create User, send verification email |
| `emailIdp.signIn(email, password)` | Issue access + refresh JWT |
| `jwtRefresh.refresh(refreshToken)` | Rotate access token |
| `session.signOut()` | Revoke current refresh token |
| `session.listActive()` | List devices/sessions for the current User |
| `session.revoke(sessionId)` | Force-sign-out a remote session |
| `password.requestReset(email)` | Mail a reset link |
| `password.completeReset(token, newPassword)` | Apply the reset |

All mutating endpoints require an `idempotencyKey` (ARCHITECTURE.md §10).

## Domain events

**Emits** (NATS subject `outbox.identity.*`):

- `UserCreated` — new account, after email verification
- `UserSignedIn` — successful auth (for `audit` + `risk`)
- `UserSignInFailed` — bad credentials (for `risk` velocity)
- `UserPasswordChanged` — manual or reset-flow change
- `SessionRevoked` — explicit or forced sign-out

**Consumes**: none. `identity` is upstream of everything.

## Cross-service calls

- **Synchronous**: none. `identity` is a root; it doesn't call other services.
- **Asynchronous**: emits only.

## Running locally

```sh
# 1. Start Postgres + Redis for this service
docker compose up --build --detach

# 2. Apply migrations + start the Serverpod server
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then:

```sh
docker compose stop
```

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.
To run alongside other services, override ports in `config/development.yaml` or pass `--api-port`, `--insights-port`, `--web-port`.

## References

- `ARCHITECTURE.md` §4 (Tier 0), §6 (happy-path step 1)
- `docs/adr/0003-service-catalog.md` (Tier 0 — Foundation)
- `CONTEXT.md` — _User, Customer, Staff, Driver_
