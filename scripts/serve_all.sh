#!/bin/sh
# Serve all 6 apps on fixed ports via web-server device, Turborepo-style.
# Streams every app's stdout/stderr to the terminal with a colored, padded
# prefix so you can read all logs at once and Ctrl+C stops the lot.
#
# Usage: sh scripts/serve_all.sh
# Stop:  sh scripts/serve_all.sh stop   (or just Ctrl+C the foreground run)
#
# Ports match docker-compose.yml so local-dev and prod URLs line up 1:1.
#   admin     → 5001
#   customer  → 5002
#   driver    → 5003
#   merchant  → 5004
#   pos       → 5005
#   kds       → 5006

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIDS_FILE="$ROOT/.serve_all.pids"
FLUTTER="$ROOT/.fvm/flutter_sdk/bin/flutter"

PORTS="5001 5002 5003 5004 5005 5006"

# Bootstrap FVM if the .fvm/flutter_sdk symlink is missing (fresh clone case).
if [ ! -L "$ROOT/.fvm/flutter_sdk" ]; then
  if ! command -v fvm >/dev/null 2>&1; then
    echo "FVM not installed. Run: dart pub global activate fvm" >&2
    exit 1
  fi
  echo "Bootstrapping FVM (one-time)..."
  (cd "$ROOT" && fvm install)
fi

stop_all() {
  if [ -f "$PIDS_FILE" ]; then
    while read -r pid; do
      kill -TERM "$pid" 2>/dev/null || true
    done < "$PIDS_FILE"
    rm -f "$PIDS_FILE"
  fi
  # Belt-and-suspenders: anything still bound to our ports, or any stray
  # flutter-run that outlasted its parent subshell.
  for port in $PORTS; do
    pids=$(lsof -ti:"$port" 2>/dev/null || true)
    [ -n "$pids" ] && echo "$pids" | xargs kill 2>/dev/null || true
  done
  pkill -f "/flutter_sdk/bin/flutter run -d web-server" 2>/dev/null || true
}

if [ "${1:-}" = "stop" ]; then
  stop_all
  echo "All servers stopped."
  exit 0
fi

# Clean previous run, then arm the trap so Ctrl+C (or any exit) tears the
# whole cohort down.
stop_all 2>/dev/null || true
: > "$PIDS_FILE"
trap 'printf "\n"; stop_all; exit 130' INT TERM

# Generated code (*.g.dart, *.freezed.dart) is required when packages use
# build_runner. No package uses it yet (Wave 0); the check below kicks in
# automatically when one is added.
HAS_CODEGEN_PKGS=$(cd "$ROOT" && grep -rl --include=pubspec.yaml '^ *build_runner:' apps packages 2>/dev/null | wc -l | tr -d ' ')
if [ "$HAS_CODEGEN_PKGS" != "0" ]; then
  echo "Running build_runner across $HAS_CODEGEN_PKGS package(s) that depend on it…"
  # Serial (--concurrency 1) and topologically ordered (--order-dependents)
  # so an upstream package's generated files land before downstream codegen
  # runs.
  if ! (cd "$ROOT" && fvm exec melos exec --concurrency 1 --order-dependents --depends-on build_runner \
        -- "dart run build_runner build --delete-conflicting-outputs"); then
    echo "build_runner failed — aborting."
    exit 1
  fi
fi

# Prefix each app's output with a colored, padded tag à la Turborepo.
# Pure sh — no awk/sed buffering quirks. `read` is line-buffered.
serve_app() {
  app=$1
  port=$2
  color=$3
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

cat <<EOF

Starting 6 apps (Ctrl+C stops all). Ports match docker-compose.
  [admin   ] http://localhost:5001
  [customer] http://localhost:5002
  [driver  ] http://localhost:5003
  [merchant] http://localhost:5004
  [pos     ] http://localhost:5005
  [kds     ] http://localhost:5006

EOF

# Color codes: 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan.
serve_app admin    5001 31
serve_app customer 5002 32
serve_app driver   5003 33
serve_app merchant 5004 34
serve_app pos      5005 35
serve_app kds      5006 36

# Stay in the foreground so logs stream and Ctrl+C reaches the trap.
wait
