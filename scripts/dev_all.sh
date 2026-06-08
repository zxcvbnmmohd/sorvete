#!/bin/sh
# Full-stack dev session: 32 Serverpod backends in Docker + 6 Flutter apps
# native (hot reload). Single Ctrl+C stops the frontends; backends keep
# running so you don't pay re-startup cost between iterations.
#
# Why this split?
# - All 32 services share container-internal port :8080 by design (the user
#   explicitly chose this). To run them simultaneously they need network
#   isolation, which Docker provides automatically — one network namespace
#   per container.
# - Flutter web apps want hot reload, which requires a live Dart VM watching
#   files. The frontend Docker image is a static nginx bundle with no VM —
#   wrong tool for dev. So frontends run native via `flutter run -d web-server`.
#
# Usage:
#   sh scripts/dev_all.sh                # default: `up`
#   sh scripts/dev_all.sh up             # bring up backends + run frontends
#   sh scripts/dev_all.sh down           # stop backends (keep data + images)
#   sh scripts/dev_all.sh reset          # stop + wipe Postgres data
#   sh scripts/dev_all.sh restart        # down then up (no data loss)
#   sh scripts/dev_all.sh status         # what's running where
#   sh scripts/dev_all.sh build          # rebuild all 38 local images

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIDS_FILE="$ROOT/.dev_all.pids"
FLUTTER="$ROOT/.fvm/flutter_sdk/bin/flutter"

GHCR_OWNER="${GHCR_OWNER:-local}"
DB_PASSWORD="${DB_PASSWORD:-devpass}"
COMPOSE="docker compose -f $ROOT/docker-compose.yml -f $ROOT/docker-compose.dev.yml"
DEV_SERVER_IMAGE="sorvete-dev-server:local"

# ----------------------------- helpers ---------------------------------------

stop_frontends() {
  if [ -f "$PIDS_FILE" ]; then
    while read -r pid; do
      kill -TERM "$pid" 2>/dev/null || true
    done < "$PIDS_FILE"
    rm -f "$PIDS_FILE"
  fi
  for port in 5001 5002 5003 5004 5005 5006; do
    pids=$(lsof -ti:"$port" 2>/dev/null || true)
    [ -n "$pids" ] && echo "$pids" | xargs kill 2>/dev/null || true
  done
  pkill -f "/flutter_sdk/bin/flutter run -d web-server" 2>/dev/null || true
}

ensure_fvm() {
  # The repo pins Flutter via .fvmrc and melos's `sdkPath: .fvm/flutter_sdk`
  # expects FVM's symlink. Auto-bootstrap on fresh clones.
  if [ ! -L "$ROOT/.fvm/flutter_sdk" ]; then
    if ! command -v fvm >/dev/null 2>&1; then
      echo "FVM not installed. Run: dart pub global activate fvm" >&2
      exit 1
    fi
    echo "=== Bootstrapping FVM (.fvmrc → Flutter $(cat "$ROOT/.fvmrc" | python3 -c "import json,sys; print(json.load(sys.stdin)['flutter'])")) ==="
    (cd "$ROOT" && fvm install)
  fi
}

ensure_images() {
  # The dev compose overrides every backend with the shared dev runtime image,
  # so production GHCR images aren't required here. Just build the dev image.
  if ! docker image inspect "$DEV_SERVER_IMAGE" >/dev/null 2>&1; then
    echo "=== Building $DEV_SERVER_IMAGE (one-time, ~1 min) ==="
    docker build -f "$ROOT/.docker/Dockerfile.server.dev" -t "$DEV_SERVER_IMAGE" "$ROOT"
  fi
}

bring_up_backends() {
  echo "=== Bringing up 32 backends + 32 Postgres in Docker ==="
  # Bring up ONLY the 32 backend services + their Postgres. Skip the 6
  # frontend containers (admin/customer/...) — those would collide with the
  # native `flutter run` on the same host ports (5001-5006).
  BACKEND_SERVICES=""
  for svc in ads analytics audit catalog config device disputes fulfillment \
             geo gift_cards identity inventory kitchen kyc loyalty marketing \
             media merchant notifications ordering payments payouts pricing \
             promotions recommendations reservations reviews risk search \
             support wallet webhooks; do
    BACKEND_SERVICES="$BACKEND_SERVICES ${svc}-server ${svc}-postgres"
  done

  env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" \
    $COMPOSE up -d --pull never $BACKEND_SERVICES 2>&1 | tail -5
  echo "=== Waiting for backends to apply migrations + listen ==="
  for i in $(seq 1 30); do
    not_ready=$(env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" \
                  $COMPOSE ps --format json 2>/dev/null \
                | python3 -c "
import json, sys
n = 0
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    obj = json.loads(line)
    if 'server' in obj['Name'] and obj.get('State') != 'running':
        n += 1
print(n)
" 2>/dev/null || echo "999")
    if [ "$not_ready" = "0" ]; then
      echo "  All 32 backends running after ${i}s."
      return 0
    fi
    sleep 1
  done
  echo "  Some backends didn't reach 'running' state in 30s — check 'docker compose logs'." >&2
}

serve_app() {
  app=$1; port=$2; color=$3
  prefix=$(printf '%-8s' "$app")
  (
    cd "$ROOT/apps/$app"
    "$FLUTTER" run -d web-server --web-port "$port" --web-hostname 0.0.0.0 \
        --dart-define=FLAVOR=local 2>&1 \
      | while IFS= read -r line; do
          printf '\033[%sm[%s]\033[0m %s\n' "$color" "$prefix" "$line"
        done
  ) &
  echo $! >> "$PIDS_FILE"
}

# ----------------------------- subcommands -----------------------------------

cmd_build() {
  sh "$ROOT/scripts/build_all.sh"
}

cmd_down() {
  stop_frontends
  env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" $COMPOSE stop 2>&1 | tail -3
  echo "Backends stopped (data + images kept)."
}

cmd_reset() {
  stop_frontends
  env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" $COMPOSE down -v 2>&1 | tail -3
  echo "Backends down + Postgres data wiped (images kept)."
}

cmd_status() {
  echo "--- Frontends (host processes on :5001-:5006) ---"
  for port in 5001 5002 5003 5004 5005 5006; do
    pid=$(lsof -ti:"$port" 2>/dev/null || echo "")
    if [ -n "$pid" ]; then
      printf "  :%s  pid %s (running)\n" "$port" "$pid"
    else
      printf "  :%s  -        (down)\n" "$port"
    fi
  done
  echo
  echo "--- Backends (Docker) ---"
  env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" $COMPOSE ps --format "table {{.Service}}\t{{.State}}\t{{.Status}}" 2>/dev/null \
    | head -10
  total=$(env GHCR_OWNER="$GHCR_OWNER" DB_PASSWORD="$DB_PASSWORD" $COMPOSE ps -q 2>/dev/null | wc -l | tr -d ' ')
  echo "  ... ($total compose-managed containers in total — expect 70 when up)"
}

cmd_up() {
  ensure_fvm
  ensure_images
  bring_up_backends
  echo
  trap 'printf "\n"; stop_frontends; echo "Frontends stopped. Backends still up — \"sh scripts/dev_all.sh down\" to stop them too."; exit 130' INT TERM
  : > "$PIDS_FILE"

  cat <<EOF

╔═══════════════════════════════════════════════════════════════════════════╗
║ Sorvete full-stack dev session                                            ║
╠═══════════════════════════════════════════════════════════════════════════╣
║ Frontends (native, hot reload via flutter run -d web-server):             ║
║   [admin   ]  http://localhost:5001    [merchant]  http://localhost:5004  ║
║   [customer]  http://localhost:5002    [pos     ]  http://localhost:5005  ║
║   [driver  ]  http://localhost:5003    [kds     ]  http://localhost:5006  ║
║                                                                           ║
║ Backends: 32 Serverpod containers in Docker network (internal only).      ║
║   docker compose ps      — list running containers                        ║
║   docker logs sorvete-<svc>-server   — tail one service's log             ║
║                                                                           ║
║ In this terminal, while frontends are running:                            ║
║   r  hot reload (preserves state)                                         ║
║   R  hot restart (resets state)                                           ║
║                                                                           ║
║ Ctrl+C stops the FRONTENDS only. Backends keep running.                   ║
║   sh scripts/dev_all.sh down    — stop backends (keep data)               ║
║   sh scripts/dev_all.sh reset   — stop + wipe Postgres data               ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF

  serve_app admin    5001 31
  serve_app customer 5002 32
  serve_app driver   5003 33
  serve_app merchant 5004 34
  serve_app pos      5005 35
  serve_app kds      5006 36

  wait
}

case "${1:-up}" in
  up|"")     cmd_up ;;
  down)      cmd_down ;;
  reset)     cmd_reset ;;
  restart)   cmd_down; cmd_up ;;
  build)     cmd_build ;;
  status)    cmd_status ;;
  -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//' ;;
  *)
    echo "Usage: $0 [up|down|reset|restart|build|status]" >&2
    exit 2
    ;;
esac
