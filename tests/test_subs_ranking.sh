#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/media_filters.sh
source "$ROOT/scripts/lib/media_filters.sh"

test_ranking_logic() {
  local input_A
  input_A="$(cat "$ROOT/tests/fixtures/eng_ita_forced_default_pgs_text.txt")"
  select_internal_subtitles "$input_A"
  local selA="${SUBTITLE_SELECTED_INDEXES}"
  echo "$selA" | grep -q " 1 "
  echo "$selA" | grep -q " 2 "
  echo "$selA" | grep -q " 4 "
  echo "$selA" | grep -q " 5 "
  echo "$selA" | grep -q " 0 " && return 1
  echo "$selA" | grep -q " 3 " && return 1
  echo "$selA" | grep -q " 6 " && return 1

  local input_B
  input_B="$(cat "$ROOT/tests/fixtures/eng_vs_rus_forced_default.txt")"
  echo "DEBUG: input_B content:"
  echo "$input_B"
  select_internal_subtitles "$input_B"
  local selB="${SUBTITLE_SELECTED_INDEXES}"
  echo "DEBUG: selB content: '$selB'"
  echo "$selB" | grep -q " 0 "
  echo "$selB" | grep -q " 1 "
  echo "$selB" | grep -q " 2 " && return 1

  echo "OK"
}
