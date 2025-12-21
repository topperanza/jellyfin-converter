#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="$ROOT/scripts/jellyfin_converter.sh"

TMP_ROOT="$(mktemp -d)"
WORKDIR="$TMP_ROOT/workdir"
INFO_BIN="$TMP_ROOT/info-bin"
STRICT_BIN="$TMP_ROOT/strict-bin"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$INFO_BIN" "$STRICT_BIN"

cat >"$INFO_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "-hide_banner" && "$2" == "-encoders" ]]; then
  echo " V..... h264_nvenc           NVENC H.264 encoder"
  exit 0
fi
exit 0
EOF

cat >"$STRICT_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "-hide_banner" && "$2" == "-encoders" ]]; then
  exit 0
fi
exit 0
EOF

cat >"$INFO_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cp "$INFO_BIN/ffprobe" "$STRICT_BIN/ffprobe"

cat >"$INFO_BIN/df" <<'EOF'
#!/usr/bin/env bash
echo "Filesystem 1024-blocks Used Available Capacity Mounted on"
echo "/dev/mock 10240000 0 2097152 0% /"
EOF
cp "$INFO_BIN/df" "$STRICT_BIN/df"

chmod +x "$INFO_BIN/"* "$STRICT_BIN/"*

INFO_LOG_DIR="$TMP_ROOT/logs-info"
STRICT_LOG_DIR="$TMP_ROOT/logs-strict"
mkdir -p "$INFO_LOG_DIR" "$STRICT_LOG_DIR"

PATH="$INFO_BIN:$PATH" \
CRF=21 \
DRY_RUN=1 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$INFO_LOG_DIR" \
PREFLIGHT_MODE=info \
"$SCRIPT_PATH" --preflight "$WORKDIR" >"$TMP_ROOT/info-output.txt"

grep -q "Preflight (info)" "$TMP_ROOT/info-output.txt"
grep -q "Free space: 2.0 GiB" "$TMP_ROOT/info-output.txt"
grep -q "CRF=21 (default: 20)" "$TMP_ROOT/info-output.txt"

set +e
PATH="$STRICT_BIN:$PATH" \
DRY_RUN=1 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$STRICT_LOG_DIR" \
PREFLIGHT_MODE=strict \
HW_ACCEL=nvenc \
"$SCRIPT_PATH" --preflight=strict "$WORKDIR" >"$TMP_ROOT/strict-output.txt" 2>&1
strict_status=$?
set -e

[[ "$strict_status" -eq 4 ]]
grep -q "Preflight failed in strict mode" "$TMP_ROOT/strict-output.txt"
