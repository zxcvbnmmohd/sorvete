#!/bin/sh
# Sort imports across all workspace packages with emoji headers.
# Uses globally-installed import_sorter to avoid pub workspace conflicts.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DART="$REPO_ROOT/.fvm/flutter_sdk/bin/dart"

DIRS="apps/admin apps/customer apps/driver apps/merchant apps/pos \
      packages/sorvete_analytics packages/sorvete_auth packages/sorvete_config \
      packages/sorvete_core packages/sorvete_data packages/sorvete_domain \
      packages/sorvete_sync packages/sorvete_ui"

for dir in $DIRS; do
  pkg="$REPO_ROOT/$dir"
  [ ! -d "$pkg" ] && continue

  # Temporary pubspec.lock (import_sorter needs it)
  cp "$REPO_ROOT/pubspec.lock" "$pkg/pubspec.lock" 2>/dev/null

  # Run import_sorter via global activation (avoids dart run + pub get)
  (cd "$pkg" && "$DART" pub global run import_sorter:main 2>/dev/null)

  # Clean up
  rm -f "$pkg/pubspec.lock"
done
