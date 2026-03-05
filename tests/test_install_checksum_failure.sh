#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
DIST_DIR="$TMP_DIR/dist"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

"$ROOT/scripts/package_release.sh" "$DIST_DIR"

# Tamper with artifact after checksum generation.
echo "tampered" >> "$DIST_DIR/release.tar.gz"

if "$ROOT/install.sh" \
  --version "v$(cat "$ROOT/VERSION")" \
  --artifact-dir "$DIST_DIR" \
  --bin-dir "$TMP_DIR/bin" \
  --install-base "$TMP_DIR/lib" \
  --skip-self-check >/dev/null 2>&1; then
  echo "installer succeeded for tampered artifact"
  exit 1
fi
