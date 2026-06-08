#!/bin/sh
# Runs tests with coverage across every package that has a test/ dir, then
# enforces a line-coverage threshold on a curated "critical" list.
#
# A package below its threshold exits the script with status 1 so CI fails.

# Don't `set -e` here — the melos exec step can surface a per-package
# failure while still producing lcov.info for the rest, which is useful
# output. We enforce the final pass/fail after inspecting thresholds.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Threshold per package. Tune as coverage improves.
# Format: "<package>:<min_line_coverage_percent>"
#
# sorvete_auth starts at 70%. Raise as the in-memory/Serverpod auth test
# suite grows.
THRESHOLDS="
sorvete_domain:80
sorvete_blocs:80
sorvete_auth:70
sorvete_core:70
"

echo "==> Running tests with coverage"
.fvm/flutter_sdk/bin/dart pub global run melos exec --dir-exists=test -- \
  "../../.fvm/flutter_sdk/bin/flutter test --coverage" || true

coverage_for() {
  lcov_path="$1"
  if [ ! -f "$lcov_path" ]; then
    echo ""
    return
  fi
  # Sum LH / LF across lcov.info: line coverage percentage.
  awk -F: '
    $1 == "LF" { total += $2 }
    $1 == "LH" { hit   += $2 }
    END {
      if (total == 0) { print "0"; }
      else { printf "%.1f", (hit / total) * 100.0; }
    }
  ' "$lcov_path"
}

fail=0
printf "\n%-22s %9s %9s\n" "Package" "Coverage" "Threshold"
printf '%s\n' "----------------------------------------------"

for entry in $THRESHOLDS; do
  [ -z "$entry" ] && continue
  pkg=$(echo "$entry" | cut -d: -f1)
  threshold=$(echo "$entry" | cut -d: -f2)

  if [ -d "packages/$pkg" ]; then
    lcov="packages/$pkg/coverage/lcov.info"
  elif [ -d "apps/$pkg" ]; then
    lcov="apps/$pkg/coverage/lcov.info"
  else
    echo "WARN: $pkg not found in workspace"
    continue
  fi

  pct=$(coverage_for "$lcov")
  if [ -z "$pct" ]; then
    printf "%-22s %9s %9s  (no lcov.info produced)\n" "$pkg" "-" "$threshold%"
    fail=1
    continue
  fi

  printf "%-22s %8s%% %8s%%" "$pkg" "$pct" "$threshold"
  # POSIX floating compare via awk.
  below=$(awk -v p="$pct" -v t="$threshold" 'BEGIN { print (p < t) ? 1 : 0 }')
  if [ "$below" = "1" ]; then
    printf "  FAIL\n"
    fail=1
  else
    printf "  ok\n"
  fi
done

exit $fail
