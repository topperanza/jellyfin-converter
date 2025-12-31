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

mkdir -p "$WORKDIR/default" "$WORKDIR/archive" "$WORKDIR/override" "$STUB_BIN" "$TMP_ROOT/logs-default" "$TMP_ROOT/logs-archive" "$TMP_ROOT/logs-override"
printf 'dummy' >"$WORKDIR/default/sample.mkv"
printf 'dummy' >"$WORKDIR/archive/archive.mkv"
printf 'dummy' >"$WORKDIR/override/override.mkv"

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${@: -1}"
echo "FFMPEG $*" >>"${FFMPEG_CALLS:-/tmp/ffmpeg_calls}"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *select_streams\ v:0*show_entries\ stream=codec_name*)
    echo "h264"
    ;;
  *select_streams\ a:0*show_entries\ stream=codec_name*)
    echo "aac"
    ;;
  *-show_entries\ stream=height*)
    echo "1080"
    ;;
  *-show_entries\ stream=channels*)
    echo "2"
    ;;
  *-show_entries\ stream=bit_rate*sample*)
    echo "36051000"
    ;;
  *-show_entries\ stream=bit_rate*override*)
    echo "36051000"
    ;;
  *-show_entries\ stream=bit_rate*)
    echo "4000000"
    ;;
  *-show_entries\ format=bit_rate*)
    echo "36051000"
    ;;
  *stream=index:stream_tags=language,title*)
    echo "0,eng,Main"
    ;;
  *)
    echo "info"
    ;;
esac
EOF

cat >"$STUB_BIN/stat" <<'EOF'
#!/usr/bin/env bash
target="${@: -1}"
case "$target" in
  *sample.mkv) echo "27616665600" ;;
  *override.mkv) echo "27616665600" ;;
  *archive.mkv) echo "104857600" ;;
  *) echo "1048576" ;;
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

# Default profile should transcode large files
CALL_LOG="$TMP_ROOT/ffmpeg_calls_default"
: >"$CALL_LOG"
PATH="$STUB_BIN:$PATH" \
FFMPEG_CALLS="$CALL_LOG" \
DRY_RUN=0 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs-default" \
OUTROOT="$TMP_ROOT/out-default" \
"$ROOT/run.sh" "$WORKDIR/default" >"$TMP_ROOT/run-default.log"

grep -q "Profile: jellyfin-1080p (default)" "$TMP_ROOT/run-default.log"
grep -q "Transcoding due to bitrate threshold" "$TMP_ROOT/run-default.log"
grep -q "FFMPEG " "$CALL_LOG"

# Verify we did NOT copy video stream (should be transcode)
if grep -q " -c copy" "$CALL_LOG"; then
  echo "FAIL: Video stream was copied, expected transcode"
  exit 1
fi

# Archive profile should allow remux
CALL_LOG="$TMP_ROOT/ffmpeg_calls_archive"
: >"$CALL_LOG"
PATH="$STUB_BIN:$PATH" \
FFMPEG_CALLS="$CALL_LOG" \
DRY_RUN=0 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs-archive" \
OUTROOT="$TMP_ROOT/out-archive" \
"$ROOT/run.sh" --profile archive "$WORKDIR/archive" >"$TMP_ROOT/run-archive.log"

grep -q "Profile: archive" "$TMP_ROOT/run-archive.log"
grep -q "Remuxing (all thresholds satisfied)" "$TMP_ROOT/run-archive.log"
grep -q "FFMPEG " "$CALL_LOG"
grep -q " -c copy" "$CALL_LOG"

# Manual overrides should beat profile defaults
CALL_LOG="$TMP_ROOT/ffmpeg_calls_override"
: >"$CALL_LOG"
PATH="$STUB_BIN:$PATH" \
FFMPEG_CALLS="$CALL_LOG" \
DRY_RUN=0 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs-override" \
OUTROOT="$TMP_ROOT/out-override" \
"$ROOT/run.sh" --no-force-transcode --max-video-bitrate-kbps 40000 --max-filesize-mb 50000 --target-height 2000 "$WORKDIR/override" >"$TMP_ROOT/run-override.log"

grep -q "Remuxing (all thresholds satisfied)" "$TMP_ROOT/run-override.log"
grep -q "Profile: jellyfin-1080p (default)" "$TMP_ROOT/run-override.log"
grep -q "FFMPEG " "$CALL_LOG"
grep -q " -c copy" "$CALL_LOG"
