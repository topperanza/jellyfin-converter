#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
STUB_BIN="$TMP_ROOT/bin"
INPUT="$TMP_ROOT/input.mkv"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$STUB_BIN"
printf 'dummy' >"$INPUT"

cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
if echo "$*" | grep -q -- "-select_streams s"; then
  echo "0|subrip|eng|English SDH|1|0|0"
  echo "1|hdmv_pgs_subtitle|rus|Main Forced|0|1|0"
  exit 0
fi
exit 0
EOF

chmod +x "$STUB_BIN/ffprobe"
PATH="$STUB_BIN:$PATH"

source "$ROOT/scripts/lib/media_filters.sh"

out="$(probe_internal_subs "$INPUT")"
[[ "$(echo "$out" | wc -l)" -eq 2 ]]
echo "$out" | grep -q "^0|subrip|eng|English SDH|1|0"
echo "$out" | grep -q "^1|hdmv_pgs_subtitle|rus|Main Forced|0|1"

select_internal_subtitles "$out"
[[ "$SUBTITLE_INTERNAL_COUNT" -eq 2 ]]
[[ "${SUBTITLE_SELECTION_MAP_ARGS[*]}" == *"0:s:0"* ]]
[[ "${SUBTITLE_SELECTION_MAP_ARGS[*]}" == *"0:s:1"* ]]

echo "OK"
