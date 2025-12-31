#!/usr/bin/env bash
echo "Starting test_subtitle_config.sh"
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Use a temp directory inside the project to satisfy safe_rm constraints
TMP_ROOT="$ROOT/tests/tmp/test_subtitle_config_$(date +%s)"
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

# Mock ffmpeg/ffprobe
cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${!#}"
echo "FFMPEG $*" >>"$FFMPEG_CALLS"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
if echo "$*" | grep -q -- "-select_streams s"; then
  # 2: Eng PGS (Bitmap)
  # 3: Spa SRT (Text)
  # 4: Rus SRT (Text)
  echo "2|hdmv_pgs_subtitle|eng|English|0|0|0"
  echo "3|subrip|spa|Spanish|0|0|0"
  echo "4|subrip|rus|Russian|0|0|0"
  exit 0
fi
case "$*" in
  *-select_streams\ v:0\ -show_entries\ stream=codec_name*) echo "h264" ;;
  *-select_streams\ a:0\ -show_entries\ stream=codec_name*) echo "aac" ;;
  *-select_streams\ a\ -show_entries\ stream=index*) echo "1" ;;
  *-select_streams\ "0:1"\ -show_entries\ stream=tags:language*) echo "eng" ;;
  *-select_streams\ v:0\ -show_entries\ stream=height*) echo "1080" ;;
  *) echo "info" ;;
esac
EOF
chmod +x "$STUB_BIN/"*
export PATH="$STUB_BIN:$PATH"

export DRY_RUN=0
export DELETE=0
export OUTROOT="$TMP_ROOT/out"
export LOG_DIR="$TMP_ROOT/logs"

# Test 1: SUB_LANGS filtering
# Input has Eng, Spa, Rus.
# Default SUB_LANGS=eng,ita -> Should keep Eng (Normal), drop Spa, drop Rus.
T1_DIR="$WORKDIR/t1"
mkdir -p "$T1_DIR"
printf 'dummy' >"$T1_DIR/test1.mkv"

if ! "$ROOT/run.sh" "$T1_DIR" > "$T1_DIR/test1.log" 2>&1; then
  echo "run.sh failed for Test 1. Log:"
  cat "$T1_DIR/test1.log"
  exit 1
fi
cmd1="$(grep "test1.mkv" "$FFMPEG_CALLS" | tail -n1)"

if [[ "$cmd1" != *"-map 0:2"* ]]; then
  echo "FAIL T1: Missing Eng PGS (0:2)"
  exit 1
fi
if [[ "$cmd1" == *"-map 0:3"* ]]; then
  echo "FAIL T1: Spa should be dropped"
  exit 1
fi
echo "PASS T1: SUB_LANGS default works"

# Test 2: Custom SUB_LANGS
# SUB_LANGS=spa,rus
T2_DIR="$WORKDIR/t2"
mkdir -p "$T2_DIR"
printf 'dummy' >"$T2_DIR/test2.mkv"
export SUB_LANGS="spa,rus"
"$ROOT/run.sh" "$T2_DIR" >/dev/null
cmd2="$(grep "test2.mkv" "$FFMPEG_CALLS" | tail -n1)"

if [[ "$cmd2" == *"-map 0:2"* ]]; then
  echo "FAIL T2: Eng should be dropped"
  exit 1
fi
if [[ "$cmd2" != *"-map 0:3"* ]]; then
  echo "FAIL T2: Spa should be kept"
  exit 1
fi
if [[ "$cmd2" != *"-map 0:4"* ]]; then
  echo "FAIL T2: Rus should be kept"
  exit 1
fi
echo "PASS T2: Custom SUB_LANGS works"

# Test 3: KEEP_BITMAP_SUBS=0
# Eng PGS (0:2) should be dropped even if Eng is wanted.
T3_DIR="$WORKDIR/t3"
mkdir -p "$T3_DIR"
printf 'dummy' >"$T3_DIR/test3.mkv"
export SUB_LANGS="eng"
export KEEP_BITMAP_SUBS=0
"$ROOT/run.sh" "$T3_DIR" >/dev/null
cmd3="$(grep "test3.mkv" "$FFMPEG_CALLS" | tail -n1)"

if [[ "$cmd3" == *"-map 0:2"* ]]; then
  echo "FAIL T3: Bitmap Eng should be dropped"
  exit 1
fi
echo "PASS T3: KEEP_BITMAP_SUBS=0 works"

# Test 4: PREFER_EXTERNAL_SUBS=0
# External Eng SRT vs Internal Eng SRT.
# We mock external file.
T4_DIR="$WORKDIR/t4"
mkdir -p "$T4_DIR"
printf 'dummy' >"$T4_DIR/test4.mkv"
printf 'dummy' >"$T4_DIR/test4.eng.srt"

# Stub update for internal
cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
if echo "$*" | grep -q -- "-select_streams s"; then
  # 2: Eng SRT (Internal)
  echo "2|subrip|eng|English|0|0|0"
  exit 0
fi
# Passthrough for others
case "$*" in
  *-select_streams\ v:0\ -show_entries\ stream=codec_name*) echo "h264" ;;
  *-select_streams\ a:0\ -show_entries\ stream=codec_name*) echo "aac" ;;
  *-select_streams\ a\ -show_entries\ stream=index*) echo "1" ;;
  *-select_streams\ "0:1"\ -show_entries\ stream=tags:language*) echo "eng" ;;
  *-select_streams\ v:0\ -show_entries\ stream=height*) echo "1080" ;;
  *) echo "info" ;;
esac
EOF
chmod +x "$STUB_BIN/ffprobe"

export SUB_LANGS="eng"
export KEEP_BITMAP_SUBS=1
export PREFER_EXTERNAL_SUBS=0

"$ROOT/run.sh" "$T4_DIR" >/dev/null
cmd4="$(grep "test4.mkv" "$FFMPEG_CALLS" | tail -n1)"

echo "CMD4: $cmd4"

if [[ "$cmd4" != *"-map 0:2"* ]]; then
  echo "FAIL T4: Internal should be preferred on tie (stable sort)"
  exit 1
fi
if [[ "$cmd4" == *"-map 1:0"* ]]; then
  echo "FAIL T4: External should not be picked"
  exit 1
fi
echo "PASS T4: PREFER_EXTERNAL_SUBS=0 works (tie-break)"

# Test 5: PREFER_EXTERNAL_SUBS=1 (Default)
# External Eng SRT vs Internal Eng SRT.
# External should win (Score 0 vs 100).
T5_DIR="$WORKDIR/t5"
mkdir -p "$T5_DIR"
printf 'dummy' >"$T5_DIR/test5.mkv"
printf 'dummy' >"$T5_DIR/test5.eng.srt"

export PREFER_EXTERNAL_SUBS=1

echo "Running Test 5..."
if ! "$ROOT/run.sh" "$T5_DIR" > "$T5_DIR/test5.log" 2>&1; then
  echo "run.sh failed for Test 5. Log:"
  cat "$T5_DIR/test5.log"
  exit 1
fi
cmd5="$(grep "test5.mkv" "$FFMPEG_CALLS" | tail -n1 || true)"
echo "CMD5: $cmd5"

if [[ "$cmd5" != *"-i $T5_DIR/test5.eng.srt"* ]]; then
  echo "FAIL T5: External sub input missing"
  exit 1
fi

if [[ "$cmd5" != *"-map 1:0"* && "$cmd5" != *"-map 1:s:0"* ]]; then
  echo "FAIL T5: External sub not mapped"
  exit 1
fi
if [[ "$cmd5" == *"-map 0:2"* ]]; then
  echo "FAIL T5: Internal sub should be dropped/secondary"
  exit 1
fi

echo "PASS T5: PREFER_EXTERNAL_SUBS=1 works"

echo "All tests passed."
