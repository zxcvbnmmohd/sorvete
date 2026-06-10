#!/usr/bin/env sh
# Wave 0 cross-service async-rail E2E — proves the outbox → relay → NATS →
# consumer → idempotent-record backbone against REAL Postgres + NATS.
#
# Run in two sequential phases so the two services don't fight over their
# shared dev ports (both default to :8080 / Postgres :8090):
#   Phase 1 — identity RELAY: an unpublished outbox row is shipped to NATS
#             (the relay stamps publishedAt).
#   Phase 2 — audit CONSUMER: an event published to outbox.identity is consumed
#             and recorded exactly once (idempotent), even on re-delivery.
#
# Usage:  sh scripts/e2e.sh        (Docker + fvm required)
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NATS_NAME=sorvete-nats-e2e
NATS_URL=${NATS_URL:-nats://localhost:4222}
export NATS_URL

# One DB password for both the Postgres container (SERVICE_DB_PASSWORD, read by
# the per-service docker-compose) and the Serverpod process
# (SERVERPOD_PASSWORD_database overrides passwords.yaml in any run mode). Shell
# env beats the gitignored .env, so this works locally and in CI (no committed
# secrets needed). Fresh each run — cleanup() removes the volume with `down -v`.
SERVICE_DB_PASSWORD="${SERVICE_DB_PASSWORD:-e2epass}"
SERVERPOD_PASSWORD_database="${SERVERPOD_PASSWORD_database:-$SERVICE_DB_PASSWORD}"
export SERVICE_DB_PASSWORD SERVERPOD_PASSWORD_database

log() { echo "── $*"; }
fail() { echo "E2E FAIL: $*" >&2; exit 1; }

cleanup() {
  pkill -f "bin/main.dart" >/dev/null 2>&1 || true
  (cd "$ROOT/services/identity/server" && docker compose down -v >/dev/null 2>&1) || true
  (cd "$ROOT/services/audit/server" && docker compose down -v >/dev/null 2>&1) || true
  docker rm -f "$NATS_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cleanup  # start from a clean slate

log "NATS (JetStream-enabled image; core pub/sub used)"
docker run -d --rm --name "$NATS_NAME" -p 4222:4222 nats:2.10-alpine -js >/dev/null

# --------------------------------------------------------------------------- #
# Phase 1 — identity relay ships an outbox row to NATS
# --------------------------------------------------------------------------- #
log "Phase 1: identity relay"
cd "$ROOT/services/identity/server"
docker compose up -d postgres >/dev/null
ipsql() { docker compose exec -T postgres psql -U postgres -d identity -tAc "$1" 2>/dev/null; }

NATS_URL="$NATS_URL" fvm dart bin/main.dart --apply-migrations >/tmp/e2e-identity.log 2>&1 &
# Generous bound: the first `dart bin/main.dart` cold-compiles in CI before the
# server boots + migrates. On failure, surface the server log.
i=0; until [ "$(ipsql "select to_regclass('public.sorvete_outbox') is not null")" = t ]; do
  i=$((i + 1)); [ "$i" -gt 480 ] && { echo "--- identity log ---"; cat /tmp/e2e-identity.log; fail "identity did not migrate"; }; sleep 0.5
done

EVID1="e2e-relay-$$"
ipsql "insert into sorvete_outbox (\"eventId\",type,\"aggregateId\",\"occurredAt\",payload,\"publishedAt\") values ('$EVID1','TestEvent','agg', now(), '{}', null)" >/dev/null
i=0; until [ "$(ipsql "select \"publishedAt\" is not null from sorvete_outbox where \"eventId\"='$EVID1'")" = t ]; do
  i=$((i + 1)); [ "$i" -gt 60 ] && fail "relay did not ship the event (publishedAt still null)"; sleep 0.5
done
log "  ✓ relay shipped $EVID1 to NATS (publishedAt set)"

pkill -f "bin/main.dart" >/dev/null 2>&1 || true
docker compose down -v >/dev/null 2>&1

# --------------------------------------------------------------------------- #
# Phase 2 — audit consumes an event from NATS and records it (idempotent)
# --------------------------------------------------------------------------- #
log "Phase 2: audit consumer"
cd "$ROOT/services/audit/server"
docker compose up -d postgres >/dev/null
apsql() { docker compose exec -T postgres psql -U postgres -d audit -tAc "$1" 2>/dev/null; }

NATS_URL="$NATS_URL" fvm dart bin/main.dart --apply-migrations >/tmp/e2e-audit.log 2>&1 &
i=0; until [ "$(apsql "select to_regclass('public.sorvete_idempotency_cache') is not null")" = t ]; do
  i=$((i + 1)); [ "$i" -gt 480 ] && { echo "--- audit log ---"; cat /tmp/e2e-audit.log; fail "audit did not migrate"; }; sleep 0.5
done

EVID2="e2e-consume-$$"
# Publish the same event id 3× — beats the subscribe race; the consumer must
# still record it exactly once (idempotent on event id).
n=0; while [ "$n" -lt 3 ]; do
  (cd "$ROOT/packages/server_kit" && NATS_URL="$NATS_URL" fvm dart run example/publish_outbox_event.dart "$EVID2" outbox.identity >/dev/null 2>&1) || true
  n=$((n + 1)); sleep 1
done
i=0; until [ "$(apsql "select count(*) from sorvete_idempotency_cache where key='audit-from-identity:$EVID2'")" = 1 ]; do
  i=$((i + 1)); [ "$i" -gt 40 ] && fail "audit did not record the event"; sleep 0.5
done
COUNT="$(apsql "select count(*) from sorvete_idempotency_cache where key='audit-from-identity:$EVID2'")"
[ "$COUNT" = 1 ] || fail "expected exactly one record, got $COUNT (idempotency broken)"
log "  ✓ audit recorded $EVID2 exactly once (idempotent across 3 publishes)"

echo "E2E PASS: async rail verified end-to-end (identity relay + audit consumer)."
