#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"
OUTROOT="$TMP_ROOT/out"
RUN_OUTPUT="$TMP_ROOT/run.log"
FFMPEG_CALLS="$TMP_ROOT/ffmpeg_calls"
export FFMPEG_CALLS

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN" "$OUTROOT" "$TMP_ROOT/logs"
printf 'dummy' >"$WORKDIR/sample.mp4"

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${@: -1}"
echo "FFMPEG_CALLED $*" >>"$FFMPEG_CALLS"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *-show_entries\ stream=codec_name*)
    echo "h264"
    ;;
  *-show_entries\ stream=height*)
    echo "1080"
    ;;
  *-show_entries\ stream=channels*)
    echo "2"
    ;;
  *stream=index:stream_tags=language,title*)
    echo "0,eng,Main"
    ;;
  *)
    echo "info"
    ;;
esac
EOF

cat >"$STUB_BIN/find" <<'EOF'
#!/usr/bin/env bash
command -v /usr/bin/find >/dev/null 2>&1 && exec /usr/bin/find "$@"
EOF

cat >"$STUB_BIN/df" <<'EOF'
#!/usr/bin/env bash
command -v /bin/df >/dev/null 2>&1 && exec /bin/df "$@"
EOF

chmod +x "$STUB_BIN/"*

PATH="$STUB_BIN:$PATH" \
DRY_RUN=0 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs" \
OUTROOT="$OUTROOT" \
"$ROOT/run.sh" "$WORKDIR" >"$RUN_OUTPUT"

grep -q "FFMPEG_CALLED" "$FFMPEG_CALLS"
[[ "$(grep -o -- ' -i ' "$FFMPEG_CALLS" | wc -l)" -eq 1 ]]
find "$OUTROOT" -name "*.mkv" | grep -q "sample.mkv"
