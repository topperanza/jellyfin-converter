#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"
OUTROOT="$TMP_ROOT/out"
FFMPEG_CALLS="$TMP_ROOT/ffmpeg_calls"
export FFMPEG_CALLS

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN" "$OUTROOT" "$TMP_ROOT/logs"

# Scenario: 1 Internal Normal (eng), 1 External Forced (eng)
# We expect both to be kept.
# External Forced -> Output Stream 0 (Score ~0)
# Internal Normal -> Output Stream 1 (Score ~150)
# Dispositions:
#   Stream 0: forced
#   Stream 1: default (because MARK_NORMAL_SUB_DEFAULT=1)

printf 'dummy' >"$WORKDIR/movie.mkv"
printf 'dummy' >"$WORKDIR/movie.eng.forced.srt"

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${!#}"
echo "FFMPEG $*" >>"$FFMPEG_CALLS"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
src="${!#}"

# Mock internal subtitles
if echo "$*" | grep -q -- "-select_streams s"; then
  # index|codec|lang|title|default|forced|hearing_impaired
  # Stream 2 is the subtitle (0=video, 1=audio assumed)
  echo "2|subrip|eng|English|0|0|0" 
  exit 0
fi

# Mock video/audio
case "$*" in
  *-select_streams\ v:0\ -show_entries\ stream=codec_name*) echo "h264" ;;
  *-select_streams\ a:0\ -show_entries\ stream=codec_name*) echo "aac" ;;
  *-select_streams\ a\ -show_entries\ stream=index*) echo "1" ;;
  *-select_streams\ "0:1"\ -show_entries\ stream=tags:language*) echo "eng" ;;
  *-select_streams\ v:0\ -show_entries\ stream=height*) echo "1080" ;;
  *-select_streams\ a:0\ -show_entries\ stream=channels*) echo "2" ;;
  *) echo "info" ;;
esac
EOF

chmod +x "$STUB_BIN/"*

export PATH="$STUB_BIN:$PATH"
export DRY_RUN=0
export DELETE=0
export MARK_NORMAL_SUB_DEFAULT=1
export OUTROOT="$OUTROOT"
export LOG_DIR="$TMP_ROOT/logs"

"$ROOT/run.sh" "$WORKDIR" >"$TMP_ROOT/run.log"

cmd="$(grep "movie.mkv" "$FFMPEG_CALLS" | head -n 1)"

echo "Captured Command: $cmd"

# Validate External Input
if [[ "$cmd" != *"-i $WORKDIR/movie.eng.forced.srt"* ]]; then
  echo "FAIL: Missing external input"
  exit 1
fi

# Validate Mappings
# External should be mapped. Input index depends on arg order.
# Video is 0. External is 1.
# Map External: -map 1:s:0
if [[ "$cmd" != *"-map 1:s:0"* ]]; then
  echo "FAIL: Missing map for external (1:s:0)"
  exit 1
fi

# Map Internal: -map 0:2
if [[ "$cmd" != *"-map 0:2"* ]]; then
  echo "FAIL: Missing map for internal (0:2)"
  exit 1
fi

# Validate Dispositions
# We need to determine output stream order.
# Based on score, External comes first.
# So Stream 0 (subtitle) -> External
# Stream 1 (subtitle) -> Internal

# Check Stream 0 is forced
if [[ "$cmd" != *"-disposition:s:0 forced"* ]]; then
  echo "FAIL: Stream 0 not forced"
  exit 1
fi

# Check Stream 1 is default (because MARK_NORMAL_SUB_DEFAULT=1)
if [[ "$cmd" != *"-disposition:s:1 default"* ]]; then
  echo "FAIL: Stream 1 not default"
  exit 1
fi

echo "PASS: Phase 4 Mapping and Dispositions verified."
