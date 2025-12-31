#!/usr/bin/env bash

setup() {
  source "scripts/lib/media_filters.sh"
  # Reset globals used by select_internal_subtitles
  SUBTITLE_SELECTION_MAP_ARGS=()
  SUBTITLE_INTERNAL_COUNT=0
  SUBTITLE_SELECTED_INDEXES=""
  # Defaults
  PREFER_SDH=0
}

test_selection_basic_eng_ita() {
  local input
  input="$(cat tests/fixtures/basic_eng_ita.txt)"
  
  select_internal_subtitles "$input"
  
  # Expect Eng Normal and Ita Normal to be selected
  # Eng (0) -> Normal
  # Ita (1) -> Normal
  
  local output="${SUBTITLE_SELECTION_MAP_ARGS[*]}"
  
  assert_contains "$output" "-map 0:0" "Should keep English"
  assert_contains "$output" "-map 0:1" "Should keep Italian"
  assert_eq "2" "$SUBTITLE_INTERNAL_COUNT" "Should select 2 tracks"
}

test_selection_multi_lang() {
  local input
  input="$(cat tests/fixtures/multi_lang.txt)"
  
  select_internal_subtitles "$input"
  
  # Eng (0), Ita (1), Rus (2), Fra (3)
  # Should keep Eng, Ita. Rus and Fra are not forced, so dropped.
  
  local output="${SUBTITLE_SELECTION_MAP_ARGS[*]}"
  
  assert_contains "$output" "-map 0:0" "Should keep English"
  assert_contains "$output" "-map 0:1" "Should keep Italian"
  assert_not_contains "$output" "-map 0:2" "Should drop Russian"
  assert_not_contains "$output" "-map 0:3" "Should drop French"
}

test_selection_all_forced() {
  local input
  input="$(cat tests/fixtures/all_forced.txt)"
  
  select_internal_subtitles "$input"
  
  # Eng Forced (0), Ita Forced (1), Rus Forced (2)
  # All forced should be kept.
  
  local output="${SUBTITLE_SELECTION_MAP_ARGS[*]}"
  
  assert_contains "$output" "-map 0:0" "Should keep English Forced"
  assert_contains "$output" "-map 0:1" "Should keep Italian Forced"
  assert_contains "$output" "-map 0:2" "Should keep Russian Forced"
}

test_selection_commentary() {
  local input
  input="$(cat tests/fixtures/commentary.txt)"
  
  select_internal_subtitles "$input"
  
  # Eng (0), Comm (1), Ita Comm (2)
  # Should keep Eng (Normal), Comm (1), Ita Comm (2)
  
  local output="${SUBTITLE_SELECTION_MAP_ARGS[*]}"
  
  assert_contains "$output" "-map 0:0" "Should keep English"
  assert_contains "$output" "-map 0:1" "Should keep Commentary 1"
  assert_contains "$output" "-map 0:2" "Should keep Commentary 2"
}
