#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
DIR1="$TMP_ROOT/case1"
DIR2="$TMP_ROOT/case2"
mkdir -p "$DIR1" "$DIR2"
printf 'x' >"$DIR1/Movie (2007).mkv"
printf 'x' >"$DIR1/Movie (2007).eng.srt"
printf 'x' >"$DIR1/Movie 2 (2019).eng.srt"
printf 'x' >"$DIR1/Movie (2007) eng.vtt"
printf 'x' >"$DIR2/Film.mkv"
printf 'x' >"$DIR2/Film.eng.srt"
printf 'x' >"$DIR2/Film.eng.sdh.srt"
printf 'x' >"$DIR2/Film.ita.forced.vtt"
printf 'x' >"$DIR2/Film.eng.commentary.ass"
# shellcheck source=scripts/lib/media_filters.sh
source "$ROOT/scripts/lib/media_filters.sh"

test_discovery_logic() {
  local out1
  out1="$(discover_external_subs "$DIR1/Movie (2007).mkv")"
  echo "DEBUG: out1='$out1'"
  echo "$out1" | grep -q "$DIR1/Movie (2007).eng.srt|eng|0|0|0|srt" || { echo "FAIL: out1 missing eng srt"; return 1; }
  echo "$out1" | grep -q "$DIR1/Movie 2 (2019).eng.srt" && { echo "FAIL: out1 has Movie 2"; return 1; }
  echo "$out1" | grep -q "$DIR1/Movie (2007) eng.vtt|eng|0|0|0|vtt" || { echo "FAIL: out1 missing eng vtt"; return 1; }

  unset PREFER_SDH
  local out2
  out2="$(discover_external_subs "$DIR2/Film.mkv")"
  echo "DEBUG: out2='$out2'"
  echo "$out2" | grep -q "$DIR2/Film.eng.srt|eng|0|0|0|srt" || { echo "FAIL: out2 missing eng srt"; return 1; }
  echo "$out2" | grep -q "$DIR2/Film.eng.sdh.srt" || { echo "FAIL: out2 missing sdh"; return 1; }
  echo "$out2" | grep -q "$DIR2/Film.ita.forced.vtt|ita|1|0|0|vtt" || { echo "FAIL: out2 missing ita forced"; return 1; }
  echo "$out2" | grep -q "$DIR2/Film.eng.commentary.ass" || { echo "FAIL: out2 missing commentary"; return 1; }

  PREFER_SDH=1
  local out3
  out3="$(discover_external_subs "$DIR2/Film.mkv")"
  echo "DEBUG: out3='$out3'"
  echo "$out3" | grep -q "$DIR2/Film.eng.sdh.srt|eng|0|1|0|srt" || { echo "FAIL: out3 missing sdh"; return 1; }
  echo "$out3" | grep -q "$DIR2/Film.eng.srt|eng|0|0|0|srt" || { echo "FAIL: out3 missing eng srt"; return 1; }
  
  return 0
}

