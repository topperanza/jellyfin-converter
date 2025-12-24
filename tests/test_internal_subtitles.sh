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

cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
orig_args=("$@")
out="${orig_args[${#orig_args[@]}-1]}"
maps=()
idx=0
while [[ "$idx" -lt "${#orig_args[@]}" ]]; do
  if [[ "${orig_args[$idx]}" == "-map" && -n "${orig_args[$((idx+1))]:-}" ]]; then
    next="${orig_args[$((idx+1))]}"
    if [[ "$next" == *":s:"* ]]; then
      maps+=("$next")
    fi
    idx=$((idx+2))
    continue
  fi
  idx=$((idx+1))
done

mkdir -p "$(dirname "$out")"
printf '%s\n' "${maps[@]}" >"${out}.subs"
echo "FFMPEG ${orig_args[*]}" >>"$FFMPEG_CALLS"
printf 'converted' >"$out"
EOF

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
src="${!#}"

if echo "$*" | grep -q -- "-select_streams s"; then
  if echo "$src" | grep -q "withsubs.mkv"; then
    echo "0,subrip,eng,English SDH,0,0"
    echo "1,hdmv_pgs_subtitle,rus,Main Forced,0,1"
    echo "2,subrip,rus,Regular,0,0"
    exit 0
  fi

  if [[ -f "${src}.subs" ]]; then
    while IFS= read -r mapped; do
      case "$mapped" in
        0:s:0) echo "0,subrip,eng,English SDH,0,0" ;;
        0:s:1) echo "1,hdmv_pgs_subtitle,rus,Main Forced,0,1" ;;
        0:s:2) echo "2,subrip,rus,Regular,0,0" ;;
        1:s:0) echo "3,subrip,eng,External,0,0" ;;
      esac
    done <"${src}.subs"
    exit 0
  fi
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
    echo "2160"
    ;;
  *-select_streams\ a:0\ -show_entries\ stream=channels*)
    echo "2"
    ;;
  *-show_entries\ stream=bit_rate*)
    echo "20000"
    ;;
  *-show_entries\ format=bit_rate*)
    echo "20000"
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
PROFILE="jellyfin-1080p" \
"$ROOT/run.sh" "$WORKDIR" >"$RUN_OUTPUT"

[[ -f "$OUTROOT/withsubs.mkv" ]]

withsubs_cmd="$(grep "withsubs.mkv" "$FFMPEG_CALLS" | head -n 1)"
[[ "$withsubs_cmd" == *"-map 0:s:0"* ]]
[[ "$withsubs_cmd" == *"-map 0:s:1"* ]]
[[ "$withsubs_cmd" != *"-map 0:s:2"* ]]

output_subs="$("$STUB_BIN/ffprobe" -v error -select_streams s -show_entries stream=index:stream_tags=language,title:stream_disposition=forced -of csv=p=0 "$OUTROOT/withsubs.mkv")"
[[ "$(echo "$output_subs" | wc -l)" -eq 2 ]]
echo "$output_subs" | grep -q "eng,English SDH"
echo "$output_subs" | grep -q "Main Forced"
! echo "$output_subs" | grep -q "Regular"
