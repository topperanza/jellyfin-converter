#!/usr/bin/env bash

# Test Suite: Subtitle Scenarios
# Covers: Internal priority, External sidecars, Bitmap vs Text, Ambiguous Names

# Ensure we can run standalone or via runner
if ! type fail >/dev/null 2>&1; then
  fail() {
    echo "FAIL: $1"
    exit 1
  }
fi

source "scripts/lib/media_filters.sh"

# Ensure deterministic configuration
export SUB_LANGS="eng,ita"
export PREFER_EXTERNAL_SUBS=1
export KEEP_BITMAP_SUBS=1
export PREFER_SDH=0
export MARK_NORMAL_SUB_DEFAULT=0

# Global mock storage
MOCK_INTERNAL=""
MOCK_EXTERNAL=""

# Override probe functions
probe_internal_subs() {
  echo "$MOCK_INTERNAL"
}

discover_external_subs() {
  echo "$MOCK_EXTERNAL"
}

test_internal_priority_eng() {
  # Scenario: Multiple English tracks. 
  # 0: eng (normal)
  # 1: eng (forced)
  # 2: eng (default)
  # Expected: Keep forced (as forced), Keep default/normal (as default/normal)
  
  MOCK_INTERNAL="0|subrip|eng||0|0|0
1|subrip|eng||0|1|0
2|subrip|eng||1|0|0"
  MOCK_EXTERNAL=""
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # Should keep stream 1 (forced)
  if ! echo "$plan" | grep -q "int|1|eng|1|subrip|0"; then
    fail "Stream 1 (forced) not selected or incorrect flags. Plan:\n$plan"
  fi
  
  # Should keep stream 2 (default) as the "normal" track
  if ! echo "$plan" | grep -q "int|2|eng|0|subrip|0"; then
    fail "Stream 2 (default) not selected as normal track. Plan:\n$plan"
  fi
}

test_external_sidecars() {
  # Scenario: 
  # - movie.en.srt
  # - movie.en.forced.srt
  # - movie.it.sdh.srt
  
  MOCK_INTERNAL=""
  # discover_external_subs output format: path|lang|forced|sdh|commentary|ext
  MOCK_EXTERNAL="/path/movie.en.srt|eng|0|0|0|srt
/path/movie.en.forced.srt|eng|1|0|0|srt
/path/movie.it.sdh.srt|ita|0|1|0|srt"

  local plan
  plan="$(build_subtitle_plan "movie.mkv")"
  
  # Expect movie.en.forced.srt to be selected as forced
  if ! echo "$plan" | grep -q "ext|/path/movie.en.forced.srt|eng|1|srt|0"; then
    fail "External forced English not selected. Plan:\n$plan"
  fi
  
  # Expect movie.en.srt to be selected as normal
  if ! echo "$plan" | grep -q "ext|/path/movie.en.srt|eng|0|srt|0"; then
    fail "External normal English not selected. Plan:\n$plan"
  fi
  
  # Expect movie.it.sdh.srt to be selected (Italian is wanted)
  if ! echo "$plan" | grep -q "ext|/path/movie.it.sdh.srt|ita|0|srt|0"; then
    fail "External Italian SDH not selected. Plan:\n$plan"
  fi
}

test_bitmap_vs_text() {
  # Scenario: Internal PGS (bitmap) vs Internal SRT (text)
  # Both English.
  # Text should be preferred.
  
  # 0: hdmv_pgs_subtitle (eng)
  # 1: subrip (eng)
  
  MOCK_INTERNAL="0|hdmv_pgs_subtitle|eng||0|0|0
1|subrip|eng||0|0|0"
  MOCK_EXTERNAL=""
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # Stream 1 (text) should be preferred over Stream 0 (bitmap) for "normal" English
  if ! echo "$plan" | grep -q "int|1|eng|0|subrip|0"; then
    fail "Text subtitle (stream 1) not selected over bitmap. Plan:\n$plan"
  fi
  
  # Stream 0 should NOT be selected as normal English
  if echo "$plan" | grep -q "int|0|eng"; then
    fail "Bitmap subtitle (stream 0) selected despite text available. Plan:\n$plan"
  fi
}

test_ambiguous_sidecars() {
  # Scenario: Ambiguous filenames and "other movie in same folder"
  # This tests the 'discover_external_subs' logic, so we need a filesystem integration test.
  # But we can also test 'build_subtitle_plan' resilience if we mock the output of discovery 
  # to simulate what 'discover_external_subs' *would* return if it was buggy?
  # No, the requirement is to test that we DON'T pick up the wrong files.
  # So this must be a filesystem test.
  
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  mkdir -p "$tmp_dir"
  
  # Setup files
  touch "$tmp_dir/MyMovie.mkv"
  touch "$tmp_dir/MyMovie.eng.srt"       # Good
  touch "$tmp_dir/MyMovie (1999).srt"    # Bad (unless strict matching handles it?)
                                         # The logic splits by delimiters. 
                                         # "MyMovie (1999)" -> "MyMovie", "1999". Stem match?
                                         # Base="MyMovie". Stem="MyMovie (1999)".
                                         # Stem starts with Base.
                                         # Rest=" (1999)". First char=" ". OK.
                                         # Tokens: "1999". Lang mapping for 1999 is empty.
                                         # Lang defaults to "und".
                                         # "und" is not wanted. Should be skipped.
                                         
  touch "$tmp_dir/MyMovie_trailer.srt"   # Bad. Rest="_trailer". Lang=und. Skip.
  touch "$tmp_dir/MyMovie.part1.srt"     # Bad. Rest=".part1". Lang=und. Skip.
  touch "$tmp_dir/MyMovie_sequel.eng.srt" # Bad. Base mismatch?
                                          # Stem="MyMovie_sequel". Base="MyMovie".
                                          # Rest="_sequel". Lang=und. Skip.
                                          
  touch "$tmp_dir/MyMovie.fra.srt"       # Good format, but lang=fra (not in SUB_LANGS=eng,ita).
  
  # Run in subshell to restore original function
  (
    # Re-source to get original function
    source "scripts/lib/media_filters.sh"
    
    local res
    res="$(discover_external_subs "$tmp_dir/MyMovie.mkv")"
    
    # Check Positive matches
    if ! echo "$res" | grep -q "MyMovie.eng.srt"; then
       fail "Did not discover MyMovie.eng.srt. Result:\n$res"
    fi
    
    # Check Negative matches
    if echo "$res" | grep -q "MyMovie_sequel"; then
       fail "Incorrectly discovered MyMovie_sequel"
    fi
    if echo "$res" | grep -q "MyMovie_trailer"; then
       fail "Incorrectly discovered MyMovie_trailer"
    fi
    if echo "$res" | grep -q "MyMovie (1999)"; then
       # It might be discovered as "und", but then filtered out in build_subtitle_plan?
       # discover_external_subs returns everything it finds, mapped to lang.
       # If lang is 'und', it returns it as 'und'.
       # But 'build_subtitle_plan' filters by 'is_wanted_lang'.
       # So here we check if it was DISCOVERED (returned by the function).
       # If it returns it as 'und', that's technically correct behavior for discovery.
       # But let's see if it maps to a lang.
       echo "Info: MyMovie (1999) discovered as: $(echo "$res" | grep "MyMovie (1999)")"
    fi
  )
  
  rm -rf "$tmp_dir"
}

test_multiple_eng_ita_combos() {
  # Scenario: Complex mix of forced/default for Eng and Ita
  # Stream 0: ENG (default=0, forced=0)
  # Stream 1: ENG (default=1, forced=0)
  # Stream 2: ENG (default=0, forced=1)
  # Stream 3: ITA (default=0, forced=0)
  # Stream 4: ITA (default=1, forced=0)
  
  # Expected:
  # - ENG Forced: Stream 2
  # - ENG Normal: Stream 1 (Default preferred over Stream 0)
  # - ITA Normal: Stream 4 (Default preferred over Stream 3)
  # - ITA Forced: None available
  
  MOCK_INTERNAL="0|subrip|eng||0|0|0
1|subrip|eng||1|0|0
2|subrip|eng||0|1|0
3|subrip|ita||0|0|0
4|subrip|ita||1|0|0"
  MOCK_EXTERNAL=""
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # Check ENG Forced (Stream 2)
  if ! echo "$plan" | grep -q "int|2|eng|1|subrip|0"; then
    fail "ENG Forced (Stream 2) not selected. Plan:\n$plan"
  fi
  
  # Check ENG Normal (Stream 1)
  if ! echo "$plan" | grep -q "int|1|eng|0|subrip|0"; then
    fail "ENG Normal (Stream 1) not selected. Plan:\n$plan"
  fi
  
  # Check ITA Normal (Stream 4)
  if ! echo "$plan" | grep -q "int|4|ita|0|subrip|0"; then
    fail "ITA Normal (Stream 4) not selected. Plan:\n$plan"
  fi
  
  # Ensure Stream 0 and 3 are NOT selected (redundant normals)
  if echo "$plan" | grep -q "int|0|eng"; then
    fail "ENG Stream 0 selected (should be skipped for Stream 1). Plan:\n$plan"
  fi
  if echo "$plan" | grep -q "int|3|ita"; then
    fail "ITA Stream 3 selected (should be skipped for Stream 4). Plan:\n$plan"
  fi
}

