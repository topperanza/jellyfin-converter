#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
DIST_DIR="$TMP_DIR/dist"
STUB_BIN="$TMP_DIR/stub-bin"
INSTALL_BASE="$TMP_DIR/install"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$STUB_BIN"

for cmd in ffmpeg ffprobe find df; do
  cat >"$STUB_BIN/$cmd" <<'CMD'
#!/usr/bin/env bash
exit 0
CMD
  chmod +x "$STUB_BIN/$cmd"
done

cat >"$STUB_BIN/df" <<'CMD'
#!/usr/bin/env bash
echo "Filesystem 512-blocks Used Available Capacity Mounted on"
echo "/dev/mock 1048576 0 1048576 1% /"
CMD
chmod +x "$STUB_BIN/df"

"$ROOT/scripts/package_release.sh" "$DIST_DIR"

[[ -f "$DIST_DIR/release.tar.gz" ]]
[[ -f "$DIST_DIR/checksums.txt" ]]
[[ -f "$DIST_DIR/install.sh" ]]

if ! grep -q "release.tar.gz" "$DIST_DIR/checksums.txt"; then
  echo "checksums.txt missing release.tar.gz entry"
  exit 1
fi

PATH="$STUB_BIN:$PATH" "$ROOT/install.sh" \
  --version "v$(cat "$ROOT/VERSION")" \
  --artifact-dir "$DIST_DIR" \
  --bin-dir "$INSTALL_BASE/bin" \
  --install-base "$INSTALL_BASE/lib"

PATH="$STUB_BIN:$PATH" "$INSTALL_BASE/bin/jellyfin-converter" --version >/dev/null
PATH="$STUB_BIN:$PATH" "$INSTALL_BASE/bin/jellyfin-converter" --help >/dev/null
PATH="$STUB_BIN:$PATH" "$INSTALL_BASE/bin/jellyfin-converter" --self-check >/dev/null

# Reinstall should be safe and keep usable binary (upgrade path)
PATH="$STUB_BIN:$PATH" "$ROOT/install.sh" \
  --version "v$(cat "$ROOT/VERSION")" \
  --artifact-dir "$DIST_DIR" \
  --bin-dir "$INSTALL_BASE/bin" \
  --install-base "$INSTALL_BASE/lib"

PATH="$STUB_BIN:$PATH" "$INSTALL_BASE/bin/jellyfin-converter" --version >/dev/null
