#!/bin/sh
# Post-bootstrap setup: git hooks + pubspec.lock symlinks for import_sorter.
# Runs as a melos post-bootstrap hook (local dev + CI), so it must never exit
# non-zero just because an optional dir is absent.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Set git hooks path (only if the dir exists — optional local-dev tooling).
if [ -d "$REPO_ROOT/.githooks" ]; then
  git config core.hooksPath .githooks
fi

# import_sorter requires a pubspec.lock in each package directory. Symlink the
# root workspace lockfile into every app/package that has a pubspec.yaml.
# Derived from the filesystem so it adapts as packages are added/removed.
for pubspec in "$REPO_ROOT"/apps/*/pubspec.yaml "$REPO_ROOT"/packages/*/pubspec.yaml; do
  [ -f "$pubspec" ] || continue
  ln -sf "$REPO_ROOT/pubspec.lock" "$(dirname "$pubspec")/pubspec.lock"
done

exit 0
