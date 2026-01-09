#!/usr/bin/env bash
echo "Starting test_ffprobe_batch.sh"
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$ROOT/tests/tmp/test_ffprobe_batch_$(date +%s)"
mkdir -p "$TMP_ROOT"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"
FFPROBE_CALLS="$TMP_ROOT/ffprobe_calls"
export FFPROBE_CALLS

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN" "$TMP_ROOT/logs"

# Mock ffprobe
cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
echo "FFPROBE $*" >>"$FFPROBE_CALLS"

# If batch probe
if [[ "$*" == *"-show_streams -show_format -of flat"* ]]; then
cat <<DATA
streams.stream.0.index=0
streams.stream.0.codec_type="video"
streams.stream.0.codec_name="h264"
streams.stream.0.width=1920
streams.stream.0.height=1080
streams.stream.0.bit_rate="5000000"
streams.stream.1.index=1
streams.stream.1.codec_type="audio"
streams.stream.1.codec_name="aac"
streams.stream.1.channels=2
streams.stream.1.tags.language="eng"
streams.stream.1.tags.title="Stereo"
format.bit_rate="6000000"
format.duration="120.0"
DATA
exit 0
fi

# Validation probe (used in process_one at end)
if [[ "$*" == *"-v error"* && "$*" != *"-show_streams"* ]]; then
  exit 0
fi

# Fallback for unexpected calls
echo ""
EOF

# Mock ffmpeg
cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
# echo "FFMPEG $*" >>"$FFPROBE_CALLS"
# Just exit success
exit 0
EOF

chmod +x "$STUB_BIN/"*
export PATH="$STUB_BIN:$PATH"

export DRY_RUN=0
export DELETE=0
export OUTROOT="$TMP_ROOT/out"
export LOG_DIR="$TMP_ROOT/logs"
export PROFILE="jellyfin-1080p"

# Helper to run conversion
run_conv() {
  local dir="$1"
  "$ROOT/run.sh" "$dir" >"$dir/run.log" 2>&1 || {
    echo "run.sh failed. Log:"
    cat "$dir/run.log"
    return 1
  }
}

echo "Test 1: Single ffprobe call per file"
T1_DIR="$WORKDIR/t1"
mkdir -p "$T1_DIR"
# Create a dummy video file
touch "$T1_DIR/test1.mkv"

run_conv "$T1_DIR"

# Count ffprobe calls for the input file
# We look for "FFPROBE" in the calls log
# We expect exactly 1 call with "-show_streams" for the input file

stream_calls=$(grep "FFPROBE" "$FFPROBE_CALLS" | grep "\-show_streams" | wc -l || true)
# Note: wc -l returns whitespace sometimes, need to trim or just use logic
stream_calls="${stream_calls// /}"

if [[ "$stream_calls" -ne 1 ]]; then
  echo "FAIL: Expected 1 ffprobe call with -show_streams, got $stream_calls"
  if [[ -f "$FFPROBE_CALLS" ]]; then
    cat "$FFPROBE_CALLS"
  else
    echo "No ffprobe calls recorded."
  fi
  # Also show run log
  cat "$T1_DIR/run.log"
  exit 1
fi

echo "PASS: Single ffprobe call verified."
