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

  case "$*" in
  *-select_streams\ v:0\ -show_entries\ stream=codec_name*)
    echo "h264"
    ;;
  *-select_streams*show_entries*stream=codec_name*)
    echo "aac"
    ;;
  *-select_streams*a*show_entries*stream=index*)
    echo "1"
    ;;
  *-select_streams*0:0*show_entries*stream=tags:language*)
    echo "eng"
    ;;
  *-select_streams*0:0*show_entries*stream=tags:title*)
    echo "Main"
    ;;
  *-select_streams*s*show_entries*stream=index,codec_name:stream_tags=language,title:stream_disposition=default,forced,hearing_impaired*)
    echo "2|subrip|eng|English SDH|0|0|1"
    echo "3|hdmv_pgs_subtitle|rus|Main Forced|0|1|0"
    echo "4|subrip|rus|Regular|0|0|0"
    ;;
  *-select_streams*s*show_entries*stream=index:stream_tags=language,title:stream_disposition=forced*)
    echo "2|eng|Subtitle (eng)|0"
    echo "3|rus|Subtitle (rus)|1"
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

test_internal_logic() {
  PATH="$STUB_BIN:$PATH" \
  DRY_RUN=0 \
  DELETE=0 \
  SKIP_DELETE_CONFIRM=1 \
  LOG_DIR="$TMP_ROOT/logs" \
  OUTROOT="$OUTROOT" \
  PROFILE="jellyfin-1080p" \
  "$ROOT/run.sh" "$WORKDIR" >"$RUN_OUTPUT"

  if [[ ! -f "$OUTROOT/withsubs.mkv" ]]; then
    echo "FAIL: Output file not created"
    return 1
  fi

  local withsubs_cmd
  withsubs_cmd="$(grep "withsubs.mkv" "$FFMPEG_CALLS" | head -n 1)"
  echo "DEBUG: withsubs_cmd='$withsubs_cmd'"
  
  if [[ "$withsubs_cmd" != *"-map 0:2"* ]]; then
    echo "FAIL: map 0:2 (Eng SDH) missing"
    echo "--- RUN OUTPUT ---"
    cat "$RUN_OUTPUT"
    echo "------------------"
    return 1
  fi
  if [[ "$withsubs_cmd" != *"-map 0:3"* ]]; then
    echo "FAIL: map 0:3 (Rus Forced) missing"
    return 1
  fi
  if [[ "$withsubs_cmd" == *"-map 0:4"* ]]; then
    echo "FAIL: map 0:4 (Rus Regular) present"
    return 1
  fi

  local output_subs
  output_subs="$("$STUB_BIN/ffprobe" -v error -select_streams s -show_entries stream=index:stream_tags=language,title:stream_disposition=forced -of csv=p=0 "$OUTROOT/withsubs.mkv")"
  echo "DEBUG: output_subs='$output_subs'"
  
  if [[ "$(echo "$output_subs" | wc -l)" -ne 2 ]]; then
    echo "FAIL: Expected 2 output subs, got $(echo "$output_subs" | wc -l)"
    return 1
  fi
  echo "$output_subs" | grep -q "Subtitle (eng)" || { echo "FAIL: Output missing Eng SDH (Subtitle (eng))"; return 1; }
  echo "$output_subs" | grep -q "Subtitle (rus)" || { echo "FAIL: Output missing Main Forced (Subtitle (rus))"; return 1; }
  echo "$output_subs" | grep -q "Regular" && { echo "FAIL: Output has Regular"; return 1; }
  
  return 0
}

