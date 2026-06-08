#!/bin/sh
# Build every Sorvete image (6 frontends + 32 backends) and tag them as
# ghcr.io/local/sorvete-<name>:dev so docker-compose.yml can `--pull never`
# against them in local dev mode.
#
# Run this whenever a Dockerfile or .fvmrc changes. Source-only changes are
# picked up at runtime — no rebuild needed for Dart/Flutter file edits when
# you're using `scripts/dev_all.sh` (frontends are native, backends only need
# rebuild when their server code changes).
#
# Usage: sh scripts/build_all.sh [--parallel N]   (default N=4)

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OWNER=local
TAG=dev
PARALLEL=4

while [ $# -gt 0 ]; do
  case "$1" in
    --parallel) PARALLEL=$2; shift 2 ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

SERVICES="ads analytics audit catalog config device disputes fulfillment geo gift_cards identity inventory kitchen kyc loyalty marketing media merchant notifications ordering payments payouts pricing promotions recommendations reservations reviews risk search support wallet webhooks"
APPS="admin customer driver kds merchant pos"

cd "$ROOT"

echo "=== Phase 1: 32 backend images (parallel=$PARALLEL) ==="
i=0
for svc in $SERVICES; do
  (
    if docker build -q -f "services/$svc/server/Dockerfile" \
                       -t "ghcr.io/$OWNER/sorvete-$svc-server:$TAG" \
                       "services/$svc" >/dev/null 2>&1; then
      echo "  ✓ $svc"
    else
      echo "  ✗ $svc FAILED — re-run with 'docker build -f services/$svc/server/Dockerfile services/$svc' to see logs"
      exit 1
    fi
  ) &
  i=$((i + 1))
  if [ $((i % PARALLEL)) -eq 0 ]; then
    wait
  fi
done
wait

echo
echo "=== Phase 2: 6 frontend images (parallel=$PARALLEL) ==="
i=0
for app in $APPS; do
  (
    if docker build -q -f .docker/Dockerfile.web \
                       --build-arg APP=$app --build-arg FLAVOR=dev \
                       -t "ghcr.io/$OWNER/sorvete-$app:$TAG" . >/dev/null 2>&1; then
      echo "  ✓ $app"
    else
      echo "  ✗ $app FAILED — re-run with 'docker build -f .docker/Dockerfile.web --build-arg APP=$app .' to see logs"
      exit 1
    fi
  ) &
  i=$((i + 1))
  if [ $((i % PARALLEL)) -eq 0 ]; then
    wait
  fi
done
wait

echo
count=$(docker image ls --format "{{.Repository}}" | grep -c "ghcr.io/$OWNER/sorvete" || echo 0)
echo "Done. $count Sorvete images now in the local registry (expect 38)."
