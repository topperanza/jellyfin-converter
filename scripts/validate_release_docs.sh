#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: VERSION must be semver (X.Y.Z), got: $VERSION"
  exit 1
fi

if ! grep -q "^## v$VERSION$" "$ROOT/CHANGELOG.md"; then
  echo "ERROR: CHANGELOG.md missing entry for v$VERSION"
  exit 1
fi

if [[ ! -f "$ROOT/docs/releases/v$VERSION.md" ]]; then
  echo "ERROR: docs/releases/v$VERSION.md is required"
  exit 1
fi

for required in "$ROOT/README.md" "$ROOT/docs/user-guide.md" "$ROOT/SECURITY.md"; do
  if [[ ! -s "$required" ]]; then
    echo "ERROR: required doc missing or empty: $required"
    exit 1
  fi
done

echo "Release docs validation passed for v$VERSION"
