# media_server

> The image vault. Direct-to-storage uploads via signed URLs, plus signed read URLs for the CDN. Every image referenced anywhere on Sorvete lands here.

**Tier**: 0 (Foundation) · **Wave first activated**: 0 · **Database**: `media` (Postgres) · **Blob store**: MinIO (S3-compatible)

## What this service owns

- **Media** — a record of an uploaded asset (key, bucket, content-type, size, owner, status: `pending` / `ready` / `quarantined`)
- **Signed-URL issuance** — for both upload (PUT) and read (GET)
- **Reference counting** (logical) — knowing who referenced which media so we don't garbage-collect live assets

The bytes live in MinIO. The `media` Postgres table is the metadata index.

## Responsibilities

- Issue presigned PUT URLs for the client to upload directly to MinIO
- Finalize an upload: confirm the object exists, set status to `ready`, emit event
- Issue presigned GET URLs (or CDN-friendly tokenized URLs) for image fetches
- Validate content-types and size limits per upload purpose (product, avatar, ID-document)
- Route ID-document uploads to the `kyc`-scoped private bucket

## Out of scope

- **Image processing (resize, blur, optimize)** → handled by an edge CDN in front of MinIO (Wave 1+)
- **KYC verification** → only the *upload* lives here; verification is owned by `kyc`
- **Receipt PDFs** → generated client-side from `pdf` package (Flutter) and emailed by `notifications`

## Endpoints (expected)

| Endpoint | Purpose |
|---|---|
| `upload.requestUrl(purpose, contentType, sizeBytes)` | Returns presigned PUT + a `mediaId` |
| `upload.finalize(mediaId)` | Confirm the object exists; flips status `pending → ready` |
| `media.getSignedUrl(mediaId, ttlSeconds)` | Returns time-limited GET URL |
| `media.getMetadata(mediaId)` | Read-only metadata |
| `media.archive(mediaId)` | Soft-delete (object kept for legal hold window, then GC'd) |

All mutating endpoints require an `idempotencyKey`.

## Domain events

**Emits** (NATS subject `outbox.media.*`):

- `MediaUploaded` — finalize succeeded
- `MediaArchived`

**Consumes**:

- `catalog.ProductArchived` — decrement reference count for product images

## Cross-service calls

- **Synchronous**: none
- **Asynchronous**: emits to `audit`, `kyc` (when purpose is `kyc_document`)

## Running locally

```sh
# Requires MinIO running (see root docker-compose.yml or platform infra)
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```

Stop with `Ctrl-C`, then `docker compose stop`.

**Default ports**: API `:8080` · Insights `:8081` · Web `:8082` · Postgres `:8090` · Redis `:8091`.

## References

- `ARCHITECTURE.md` §2 (Object storage), §4 (Tier 0)
- `docs/adr/0003-service-catalog.md`
