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
printf 'dummy' >"$WORKDIR/withsubs.mkv"
printf 'dummy' >"$WORKDIR/nosubs.mp4"
printf 'dummy' >"$WORKDIR/withsubs.eng.srt"

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
out="${@: -1}"
echo "FFMPEG $*" >>"$FFMPEG_CALLS"
mkdir -p "$(dirname "$out")"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
src="${@: -1}"

if echo "$*" | grep -q -- "-select_streams s"; then
  if echo "$src" | grep -q "withsubs"; then
    echo "0,subrip,eng,English SDH"
    echo "1,subrip,und,Director Commentary"
  fi
  exit 0
fi

case "$*" in
  *-select_streams\ v:0\ -show_entries\ stream=codec_name*)
    echo "h264"
    ;;
  *-select_streams\ a:0\ -show_entries\ stream=codec_name*)
    echo "aac"
    ;;
  *-select_streams\ a\ -show_entries\ stream=index:stream_tags=language,title*)
    echo "0,eng,Main"
    ;;
  *-select_streams\ v:0\ -show_entries\ stream=height*)
    echo "1080"
    ;;
  *-select_streams\ a:0\ -show_entries\ stream=channels*)
    echo "2"
    ;;
  *-show_entries\ stream=bit_rate*)
    echo "1000"
    ;;
  *-show_entries\ format=bit_rate*)
    echo "1000"
    ;;
  *)
    echo "info"
    ;;
esac
EOF

chmod +x "$STUB_BIN/"*

PATH="$STUB_BIN:$PATH" \
DRY_RUN=0 \
DELETE=0 \
SKIP_DELETE_CONFIRM=1 \
LOG_DIR="$TMP_ROOT/logs" \
OUTROOT="$OUTROOT" \
"$ROOT/run.sh" "$WORKDIR" >"$RUN_OUTPUT"

withsubs_cmd="$(grep "withsubs.mkv" "$FFMPEG_CALLS" | head -n 1)"
nosubs_cmd="$(grep "nosubs" "$FFMPEG_CALLS" | head -n 1)"

[[ "$withsubs_cmd" == *"-map 0:s:0"* ]]
[[ "$withsubs_cmd" == *"-map 0:s:1"* ]]
[[ "$withsubs_cmd" == *"-map 1:s:0"* ]]
[[ "$nosubs_cmd" != *":s:"* ]]
