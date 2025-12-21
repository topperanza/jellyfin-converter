#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="$ROOT/scripts/jellyfin_converter.sh"

TMP_ROOT="$(mktemp -d)"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN"

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

chmod +x "$STUB_BIN/ffmpeg" "$STUB_BIN/ffprobe"

PATH="$STUB_BIN:$PATH" \
DRY_RUN=1 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
"$SCRIPT_PATH" "$WORKDIR"

test -d "$WORKDIR/converted"
test -f "$ROOT/logs/conversion.log"
test -f "$ROOT/logs/.processed"
test -f "$ROOT/examples/env.dry-run.example"
test -f "$ROOT/examples/env.hw-accel.example"
grep -q "DRY_RUN=1" "$ROOT/examples/env.dry-run.example"
grep -q "DELETE=0" "$ROOT/examples/env.dry-run.example"
grep -q "DRY_RUN=1" "$ROOT/examples/env.hw-accel.example"
grep -q "DELETE=0" "$ROOT/examples/env.hw-accel.example"

rm -f "$ROOT/logs/conversion.log" "$ROOT/logs/.processed"
