#!/bin/sh
# Sorvete server dev-mode entrypoint.
# Runs Dart in JIT mode; restarts the server whenever a watched file changes.
#
# Watched paths (host edits trigger restart):
#   /app/server/lib/
#   /app/server/bin/
#   /app/server/pubspec.yaml
#   /app/server/config/

set -e

cd /app
echo ">>> Resolving workspace dependencies..."
dart pub get >/dev/null 2>&1 || dart pub get   # quiet first try, verbose retry on fail

cd /app/server

DART_PID=""

start_server() {
  echo ">>> $(date +%H:%M:%S) Starting Dart server (JIT, --mode=production --apply-migrations)..."
  # --mode=production: read config/production.yaml so Serverpod uses the docker-network
  #   hostnames ("<svc>-postgres") instead of localhost. Dev iteration mode is still
  #   JIT + auto-restart on file change — only the config file selection differs.
  dart run bin/main.dart --mode=production --apply-migrations &
  DART_PID=$!
}

stop_server() {
  if [ -n "$DART_PID" ] && kill -0 "$DART_PID" 2>/dev/null; then
    kill -TERM "$DART_PID" 2>/dev/null || true
    wait "$DART_PID" 2>/dev/null || true
  fi
  DART_PID=""
}

cleanup() {
  echo ">>> $(date +%H:%M:%S) Container shutting down — stopping server"
  stop_server
  exit 0
}

trap cleanup INT TERM

start_server

# Watch loop. inotifywait blocks until a single event fires, then we restart.
# -qq quiet, -e events to watch, -r recursive.
while true; do
  # `attrib` covers `touch` (utimensat) — useful when editors save via atomic
  # rename + chmod patterns that don't always fire `modify` through the macOS
  # → OrbStack bind-mount layer.
  inotifywait -qq -e modify,create,delete,move,attrib \
    -r lib bin pubspec.yaml config 2>/dev/null || sleep 1
  echo ">>> $(date +%H:%M:%S) Change detected — restarting"
  stop_server
  # If pubspec changed, re-resolve workspace deps.
  ( cd /app && dart pub get >/dev/null 2>&1 ) || true
  start_server
done
