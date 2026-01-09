#!/usr/bin/env bash
echo "Starting test_ffprobe_lang_und.sh"
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$ROOT/tests/tmp/test_ffprobe_lang_und_$(date +%s)"
mkdir -p "$TMP_ROOT"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"
FFMPEG_CALLS="$TMP_ROOT/ffmpeg_calls"
export FFMPEG_CALLS

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN" "$TMP_ROOT/logs"

# Mock ffmpeg
cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${!#}"
echo "FFMPEG $*" >>"$FFMPEG_CALLS"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

# Mock find/df
cat >"$STUB_BIN/find" <<'EOF'
#!/usr/bin/env bash
command -v /usr/bin/find >/dev/null 2>&1 && exec /usr/bin/find "$@"
EOF

cat >"$STUB_BIN/df" <<'EOF'
#!/usr/bin/env bash
command -v /bin/df >/dev/null 2>&1 && exec /bin/df "$@"
EOF

# Mock ffprobe (batch style)
cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
# echo "FFPROBE $*" >>"$FFMPEG_CALLS" # Optional debugging

# Check if batch probe
if [[ "$*" == *"-show_streams -show_format -of flat"* ]]; then
  
  input_file=""
  for arg in "$@"; do
    if [[ "$arg" == *.mkv ]]; then
      input_file="$arg"
      break
    fi
  done

  print_video() {
    cat <<DATA
streams.stream.0.index=0
streams.stream.0.codec_type="video"
streams.stream.0.codec_name="h264"
streams.stream.0.width=1920
streams.stream.0.height=1080
DATA
  }

  if [[ "$input_file" == *"test1.mkv"* || "$input_file" == *"test1b.mkv"* ]]; then
    # Case 1: Audio with missing/empty language (or "und")
    print_video
    cat <<DATA
streams.stream.1.index=1
streams.stream.1.codec_type="audio"
streams.stream.1.codec_name="aac"
streams.stream.1.channels=2
streams.stream.1.tags.language="und"
streams.stream.1.tags.title="Audio 1"
format.duration="120.0"
DATA
    exit 0

  elif [[ "$input_file" == *"test2.mkv"* ]]; then
    # Case 2: Subtitle 'und' NOT forced
    print_video
    cat <<DATA
streams.stream.1.index=1
streams.stream.1.codec_type="audio"
streams.stream.1.codec_name="aac"
streams.stream.1.tags.language="eng"
streams.stream.2.index=2
streams.stream.2.codec_type="subtitle"
streams.stream.2.codec_name="subrip"
streams.stream.2.tags.language="und"
streams.stream.2.disposition.forced=0
streams.stream.2.disposition.default=0
format.duration="120.0"
DATA
    exit 0

  elif [[ "$input_file" == *"test3.mkv"* ]]; then
    # Case 3: Subtitle 'und' FORCED
    print_video
    cat <<DATA
streams.stream.1.index=1
streams.stream.1.codec_type="audio"
streams.stream.1.codec_name="aac"
streams.stream.1.tags.language="eng"
streams.stream.2.index=2
streams.stream.2.codec_type="subtitle"
streams.stream.2.codec_name="subrip"
streams.stream.2.tags.language="und"
streams.stream.2.disposition.forced=1
streams.stream.2.disposition.default=0
format.duration="120.0"
DATA
    exit 0
  fi

  exit 1
fi

# Fallback for validation probe
if [[ "$*" == *"-v error"* ]]; then
  exit 0
fi

exit 1
EOF

chmod +x "$STUB_BIN/"*
export PATH="$STUB_BIN:$PATH"

export DRY_RUN=0
export DELETE=0
export OUTROOT="$TMP_ROOT/out"
export LOG_DIR="$TMP_ROOT/logs"
export PROFILE="jellyfin-1080p"
export SUB_LANGS="eng,ita"

run_conv() {
  local dir="$1"
  shift
  "$ROOT/run.sh" "$dir" "$@" >"$dir/run.log" 2>&1
}

# Test 1a: Audio with 'und' -> DROPPED by default (fallback kicks in)
echo "Test 1a: Audio 'und' -> DROPPED by default (fallback used)"
T1_DIR="$WORKDIR/t1"
mkdir -p "$T1_DIR"
printf 'dummy' >"$T1_DIR/test1.mkv"

run_conv "$T1_DIR"
cmd1="$(grep "test1.mkv" "$FFMPEG_CALLS" | tail -n1)"

# Check if fallback message is in log
if ! grep -q "No audio tracks selected, keeping all audio tracks" "$T1_DIR/run.log"; then
  echo "FAIL T1a: Expected fallback message (und audio dropped)"
  cat "$T1_DIR/run.log"
  exit 1
fi
echo "PASS T1a: 'und' audio dropped (fallback triggered)"

# Test 1b: Audio 'und' -> KEPT with --allow-und-audio
echo "Test 1b: Audio 'und' -> KEPT with --allow-und-audio"
T1B_DIR="$WORKDIR/t1b"
mkdir -p "$T1B_DIR"
printf 'dummy' >"$T1B_DIR/test1b.mkv"

run_conv "$T1B_DIR" --allow-und-audio
cmd1b="$(grep "test1b.mkv" "$FFMPEG_CALLS" | tail -n1)"

# Check if fallback message is ABSENT
if grep -q "No audio tracks selected, keeping all audio tracks" "$T1B_DIR/run.log"; then
  echo "FAIL T1b: Fallback triggered, but 'und' should have been explicitly selected"
  cat "$T1B_DIR/run.log"
  exit 1
fi
# Check if map arg exists (0:1)
if [[ "$cmd1b" != *"-map 0:1"* ]]; then
  echo "FAIL T1b: Audio track 0:1 not mapped explicitly"
  echo "Command: $cmd1b"
  exit 1
fi
echo "PASS T1b: 'und' audio kept with flag"


# Test 2: Subtitle 'und' -> DROPPED by default
echo "Test 2: Subtitle 'und' not forced -> DROPPED by default"
T2_DIR="$WORKDIR/t2"
mkdir -p "$T2_DIR"
printf 'dummy' >"$T2_DIR/test2.mkv"

run_conv "$T2_DIR"
cmd2="$(grep "test2.mkv" "$FFMPEG_CALLS" | tail -n1)"

if [[ "$cmd2" == *"-map 0:2"* ]]; then
  echo "FAIL T2: Undefined subtitle should be dropped"
  echo "Command: $cmd2"
  exit 1
fi
echo "PASS T2: Undefined subtitle dropped"


# Test 3: Subtitle 'und' forced -> KEPT
echo "Test 3: Subtitle 'und' forced -> KEPT"
T3_DIR="$WORKDIR/t3"
mkdir -p "$T3_DIR"
printf 'dummy' >"$T3_DIR/test3.mkv"

run_conv "$T3_DIR"
cmd3="$(grep "test3.mkv" "$FFMPEG_CALLS" | tail -n1)"

if [[ "$cmd3" != *"-map 0:2"* ]]; then
  echo "FAIL T3: Undefined forced subtitle should be kept"
  echo "Command: $cmd3"
  exit 1
fi
echo "PASS T3: Undefined forced subtitle kept"

echo "Done."
