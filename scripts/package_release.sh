#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${1:-$ROOT/dist}"
VERSION_FILE="$ROOT/VERSION"
export LC_ALL=C
export LANG=C

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "ERROR: VERSION file missing"
  exit 1
fi

read -r VERSION <"$VERSION_FILE"
if [[ -z "$VERSION" ]]; then
  echo "ERROR: VERSION is empty"
  exit 1
fi

STAGE_DIR="$DIST_DIR/stage"
PKG_ROOT="$STAGE_DIR/jellyfin-converter-$VERSION"
TARBALL="$DIST_DIR/release.tar.gz"
CHECKSUM_FILE="$DIST_DIR/checksums.txt"

rm -rf "$STAGE_DIR"
mkdir -p "$PKG_ROOT" "$DIST_DIR"

for path in run.sh scripts docs examples config VERSION LICENSE README.md SECURITY.md CHANGELOG.md; do
  cp -R "$ROOT/$path" "$PKG_ROOT/"
done

if [[ -f "$ROOT/install.sh" ]]; then
  cp "$ROOT/install.sh" "$DIST_DIR/install.sh"
fi
cp "$ROOT/VERSION" "$DIST_DIR/VERSION"
cp "$ROOT/CHANGELOG.md" "$DIST_DIR/CHANGELOG.md"

if tar --version 2>/dev/null | grep -q "GNU tar"; then
  tar --sort=name --format=posix --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$TARBALL" -C "$STAGE_DIR" "jellyfin-converter-$VERSION"
else
  tar -czf "$TARBALL" -C "$STAGE_DIR" "jellyfin-converter-$VERSION"
fi

sha256_file() {
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    local sum
    sum="$(sha256sum "$f" | awk '{print $1}')"
    echo "$sum  $(basename "$f")"
  else
    local sum
    sum="$(shasum -a 256 "$f" | awk '{print $1}')"
    echo "$sum  $(basename "$f")"
  fi
}

: >"$CHECKSUM_FILE"
for asset in release.tar.gz install.sh VERSION CHANGELOG.md; do
  if [[ -f "$DIST_DIR/$asset" ]]; then
    sha256_file "$DIST_DIR/$asset" >>"$CHECKSUM_FILE"
  fi
done

rm -rf "$STAGE_DIR"

echo "Packaged $VERSION"
echo "  Tarball: $TARBALL"
echo "  Checksums: $CHECKSUM_FILE"
