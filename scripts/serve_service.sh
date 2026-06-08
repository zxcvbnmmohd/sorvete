#!/bin/sh
# Start, stop, generate, or test a single Serverpod microservice.
# Service names are auto-discovered from services/*/<name>_server.
#
# Usage:
#   sh scripts/serve_service.sh up        <name>   docker compose up -d + wait healthy
#   sh scripts/serve_service.sh down      <name>   docker compose down -v
#   sh scripts/serve_service.sh run       <name>   up + dart bin/main.dart (foreground)
#   sh scripts/serve_service.sh gen       <name>   serverpod generate
#   sh scripts/serve_service.sh test      <name>   docker up + dart test + docker down
#   sh scripts/serve_service.sh list                 list discovered services
#
# The "up" subcommand is what VS Code's `service: docker compose up` task wires
# to via preLaunchTask. The Dart launch then attaches to the server process so
# breakpoints and hot-reload work as usual.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVICES_DIR="$ROOT/services"

usage() {
  cat <<EOF
Usage: sh scripts/serve_service.sh <command> [<name>]

Commands:
  up    <name>   docker compose up -d (waits for Postgres healthy)
  down  <name>   docker compose down -v
  run   <name>   up + dart bin/main.dart --apply-migrations (foreground)
  gen   <name>   run serverpod generate
  test  <name>   docker up + dart test + docker down
  list           list discovered services

Discovered services:
EOF
  for svc in "$SERVICES_DIR"/*/; do
    [ -d "$svc" ] || continue
    name=$(basename "$svc")
    [ -d "$svc/server" ] || continue
    echo "  $name"
  done
}

assert_service() {
  name=$1
  if [ -z "$name" ]; then
    echo "error: service name required" >&2
    usage >&2
    exit 2
  fi
  dir="$SERVICES_DIR/$name/server"
  if [ ! -d "$dir" ]; then
    echo "error: no such service '$name' (expected $dir)" >&2
    exit 2
  fi
}

wait_for_postgres() {
  # docker-compose.yaml in the service exposes postgres on :8090 by default
  # (per the Serverpod template). Poll until it accepts connections.
  name=$1
  dir="$SERVICES_DIR/$name/server"
  echo "[$name] waiting for Postgres to accept connections..."
  attempts=0
  until (cd "$dir" && docker compose exec -T postgres pg_isready -U postgres -q 2>/dev/null); do
    attempts=$((attempts + 1))
    if [ "$attempts" -gt 30 ]; then
      echo "[$name] Postgres did not become ready after 30s" >&2
      return 1
    fi
    sleep 1
  done
  echo "[$name] Postgres is ready."
}

cmd_up() {
  name=$1
  assert_service "$name"
  dir="$SERVICES_DIR/$name/server"
  echo "[$name] docker compose up -d"
  (cd "$dir" && docker compose up --quiet-pull -d)
  wait_for_postgres "$name"
}

cmd_down() {
  name=$1
  assert_service "$name"
  dir="$SERVICES_DIR/$name/server"
  echo "[$name] docker compose down -v"
  (cd "$dir" && docker compose down -v)
}

cmd_gen() {
  name=$1
  assert_service "$name"
  dir="$SERVICES_DIR/$name/server"
  echo "[$name] serverpod generate"
  (cd "$dir" && serverpod generate)
}

cmd_run() {
  name=$1
  assert_service "$name"
  cmd_up "$name"
  dir="$SERVICES_DIR/$name/server"
  echo "[$name] dart bin/main.dart --apply-migrations"
  trap 'echo; echo "[$name] Ctrl+C — leaving Docker up. Run \"$0 down $name\" to stop containers."; exit 130' INT TERM
  (cd "$dir" && dart bin/main.dart --apply-migrations)
}

cmd_test() {
  name=$1
  assert_service "$name"
  dir="$SERVICES_DIR/$name/server"
  cmd_up "$name"
  trap '(cd "$dir" && docker compose down -v) || true' EXIT
  echo "[$name] dart test"
  (cd "$dir" && dart test)
}

cmd_list() {
  for svc in "$SERVICES_DIR"/*/; do
    [ -d "$svc" ] || continue
    name=$(basename "$svc")
    [ -d "$svc/server" ] || continue
    echo "$name"
  done
}

cmd=${1:-}
case "$cmd" in
  up)    shift; cmd_up   "${1:-}" ;;
  down)  shift; cmd_down "${1:-}" ;;
  gen)   shift; cmd_gen  "${1:-}" ;;
  run)   shift; cmd_run  "${1:-}" ;;
  test)  shift; cmd_test "${1:-}" ;;
  list)  cmd_list ;;
  -h|--help|help|"") usage ;;
  *)
    echo "error: unknown command '$cmd'" >&2
    usage >&2
    exit 2
    ;;
esac
