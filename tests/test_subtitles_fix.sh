#!/usr/bin/env bash

# Test script for subtitle fixes and nounset robustness
# Run from project root

set -u

TEST_TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT

SCRIPT_DIR="$(pwd)/scripts"
CONVERTER="$SCRIPT_DIR/jellyfin_converter.sh"

# shellcheck source=scripts/lib/media_filters.sh
source "$SCRIPT_DIR/lib/media_filters.sh"

# Mock to_lower/to_upper if compat.sh wasn't loaded correctly
if ! command -v to_lower >/dev/null; then
  to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
  to_upper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
  have_bash_ge_4() { return 1; }
fi

test_suite_logic() {
  echo "=== Testing Subtitle Fixes & Hardening ==="

  # 1. Unit Test for Internal Subtitle Selection
  echo "--- Unit Test: select_internal_subtitles ---"

  # Case A: Preferred (Eng) exists
  # stream_idx, codec, lang, title, default, forced
  local info_A=$'2,subrip,eng,English,0,0\n3,subrip,rus,Russian,0,0'
  assert_selection "Preferred (Eng) over Russian" "$info_A" "-map 0:2" "-map 0:3" || return 1

  # Case B: Only Russian (Fallback)
  local info_B=$'3,subrip,rus,Russian,0,0'
  assert_selection "Only Russian (Fallback)" "$info_B" "-map 0:3" "" || return 1

  # Case C: Non-Russian (French) vs Russian -> Prefer French
  local info_C=$'4,subrip,fra,French,0,0\n5,subrip,rus,Russian,0,0'
  assert_selection "Non-Russian (French) over Russian" "$info_C" "-map 0:4" "-map 0:5" || return 1

  # Case D: Forced subs
  local info_D=$'6,subrip,spa,Spanish,0,1\n7,subrip,rus,Russian,0,0'
  assert_selection "Forced subs kept" "$info_D" "-map 0:6" "" || return 1

  # Case E: Commentary
  local info_E=$'8,subrip,und,Director Commentary,0,0'
  assert_selection "Commentary kept" "$info_E" "-map 0:8" "" || return 1


  # 2. Integration Test: No Subtitles Crash
  echo "--- Integration Test: No Subtitles (Crash Check) ---"

  local INPUT_VIDEO="$TEST_TEMP_DIR/input_nosubs.mkv"
  # Generate 1s video, no audio, no subs
  ffmpeg -f lavfi -i testsrc=duration=1:size=640x360:rate=1 -c:v libx264 "$INPUT_VIDEO" >/dev/null 2>&1

  local OUT_DIR="$TEST_TEMP_DIR/out"
  mkdir -p "$OUT_DIR"

  # Run with DRY_RUN=0 to trigger all logic
  # We expect exit code 0 and output file created
  # Pass SCAN_DIR via env, omit argument to ensure env usage
  # Set DELETE=0 and SKIP_DELETE_CONFIRM=1 to avoid interactive prompts
  OUTROOT="out" SCAN_DIR="$TEST_TEMP_DIR" DRY_RUN=0 DELETE=0 SKIP_DELETE_CONFIRM=1 "$CONVERTER" > "$TEST_TEMP_DIR/run.log" 2>&1
  local RUN_STATUS=$?

  if [[ $RUN_STATUS -ne 0 ]]; then
    echo "FAIL: Converter exited with $RUN_STATUS"
    cat "$TEST_TEMP_DIR/run.log"
    return 1
  fi

  if ! grep -q "No subtitles selected" "$TEST_TEMP_DIR/run.log"; then
    echo "WARNING: Log did not contain 'No subtitles selected'"
  fi

  local OUTPUT_VIDEO="$TEST_TEMP_DIR/out/input_nosubs.mkv"
  if [[ ! -f "$OUTPUT_VIDEO" ]]; then
    echo "FAIL: Output video not created"
    return 1
  fi

  echo "PASS: No-subtitles integration test passed"
}

assert_selection() {
  local name="$1"
  local input="$2"
  local expected_map="$3" # substring to look for
  local forbidden_map="$4" # substring that must NOT be present

  echo "Test Case: $name"
  select_internal_subtitles "$input"
  
  local output="${SUBTITLE_SELECTION_MAP_ARGS[*]:-}"
  
  if [[ -n "$expected_map" ]]; then
    if [[ "$output" != *"$expected_map"* ]]; then
      echo "FAIL: Expected '$expected_map' not found in '$output'"
      return 1
    fi
  fi
  
  if [[ -n "$forbidden_map" ]]; then
    if [[ "$output" == *"$forbidden_map"* ]]; then
      echo "FAIL: Forbidden '$forbidden_map' found in '$output'"
      return 1
    fi
  fi
  
  echo "PASS"
  return 0
}
