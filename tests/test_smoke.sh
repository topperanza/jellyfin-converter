#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

cat >"$STUB_BIN/df" <<'EOF'
#!/usr/bin/env bash
echo "Filesystem 512-blocks Used Available Capacity Mounted on"
echo "/dev/mock 1048576 0 1048576 1% /"
EOF

cat >"$STUB_BIN/find" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

chmod +x "$STUB_BIN/"*

HELP_OUTPUT="$TMP_ROOT/help.txt"
PATH="$STUB_BIN:$PATH" "$ROOT/run.sh" --help >"$HELP_OUTPUT"
grep -q "Usage: jellyfin_converter.sh" "$HELP_OUTPUT"

RUN_OUTPUT="$TMP_ROOT/run.txt"
PATH="$STUB_BIN:$PATH" \
DRY_RUN=1 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs" \
"$ROOT/run.sh" "$WORKDIR" >"$RUN_OUTPUT"

grep -q "Dry run: 1" "$RUN_OUTPUT"
grep -q "converted" "$RUN_OUTPUT"
grep -q "DRY-RUN MODE: no files will be modified" "$RUN_OUTPUT"
