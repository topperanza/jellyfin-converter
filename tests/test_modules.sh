#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_BIN="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_BIN"
}
trap cleanup EXIT

source "$ROOT/scripts/lib/media_filters.sh"
source "$ROOT/scripts/lib/ffmpeg.sh"

cat >"$TMP_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *uhd*) echo "2160" ;;
  *hd*) echo "1080" ;;
  *sd*) echo "480" ;;
  *) echo "720" ;;
esac
EOF
chmod +x "$TMP_BIN/ffprobe"
PATH="$TMP_BIN:$PATH"

[[ "$(map_lang en)" == "eng" ]]
[[ "$(map_lang ita)" == "ita" ]]
[[ "$(map_lang jp)" == "jpn" ]]

audio_info=$'0,eng,\n1,rus,\n2,,Commentary track'
declare -a audio_map_args russian_tracks
has_eng_or_ita=0
has_non_russian=0
build_audio_map_args "$audio_info" audio_map_args russian_tracks has_eng_or_ita has_non_russian
finalize_audio_selection audio_map_args russian_tracks "$has_eng_or_ita" "$has_non_russian"
[[ "${audio_map_args[*]}" == *"0:a:0"* ]]
[[ "${audio_map_args[*]}" == *"0:a:2"* ]]
[[ "${#russian_tracks[@]}" -eq 1 ]]
[[ "$has_eng_or_ita" -eq 1 ]]

declare -a sub_inputs sub_langs sub_forced sub_files
sub_idx=0
collect_subtitle "/tmp/sample.base.en.srt" "sample.base" sub_inputs sub_langs sub_forced sub_files sub_idx
collect_subtitle "/tmp/sample.base.commentary.srt" "sample.base" sub_inputs sub_langs sub_forced sub_files sub_idx
[[ "${sub_inputs[0]}" == "-i" && "${sub_inputs[2]}" == "-i" ]]
[[ "${sub_langs[0]}" == "eng" && "${sub_langs[1]}" == "und" ]]
[[ "$sub_idx" -eq 2 ]]

[[ "$(get_optimal_crf "$TMP_BIN/file.uhd")" == "22" ]]
[[ "$(get_optimal_crf "$TMP_BIN/file.hd")" == "20" ]]
[[ "$(get_optimal_crf "$TMP_BIN/file.sd")" == "23" ]]
