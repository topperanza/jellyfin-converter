#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$ROOT/scripts/lib/media_filters.sh"

input_A="$(cat "$ROOT/tests/fixtures/eng_ita_forced_default_pgs_text.txt")"
select_internal_subtitles "$input_A"
selA="${SUBTITLE_SELECTED_INDEXES}"
echo "$selA" | grep -q " 1 "
echo "$selA" | grep -q " 2 "
echo "$selA" | grep -q " 4 "
echo "$selA" | grep -q " 5 "
! echo "$selA" | grep -q " 0 "
! echo "$selA" | grep -q " 3 "
! echo "$selA" | grep -q " 6 "

input_B="$(cat "$ROOT/tests/fixtures/eng_vs_rus_forced_default.txt")"
select_internal_subtitles "$input_B"
selB="${SUBTITLE_SELECTED_INDEXES}"
echo "$selB" | grep -q " 0 "
echo "$selB" | grep -q " 1 "
! echo "$selB" | grep -q " 2 "

echo "OK"
