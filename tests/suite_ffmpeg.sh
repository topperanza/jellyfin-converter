#!/usr/bin/env bash
# shellcheck disable=SC2329

# Mock ffprobe
ffprobe() {
  # echo "MOCK FFPROBE: $*" >&2
  echo "$FFPROBE_OUTPUT"
}

setup() {
  source "scripts/lib/media_filters.sh"
  export FFPROBE_OUTPUT=""
  export PREFER_SDH=0
  export INCLUDE_COMMENTARY=1
  export MARK_NORMAL_SUB_DEFAULT=0
}

test_plan_mixed_sources() {
  # Setup Mock Data
  # Internal: 0|subrip|eng|English|0|0|0
  # External: /path/to/ext.srt|ita|1|0|0|srt
  
  # Override probe_internal_subs to return fixed string (easiest way to mock)
  probe_internal_subs() {
    echo "0|subrip|eng|English|0|0|0"
  }
  
  discover_external_subs() {
    echo "/path/to/ext.srt|ita|1|0|0|srt"
  }
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # Expected Plan:
  # Internal Eng Normal -> Keep (int|0|eng|0|subrip|0)
  # External Ita Forced -> Keep (ext|/path/to/ext.srt|ita|1|srt|0)
  
  assert_contains "$plan" "int|0|eng|0|subrip|0"
  assert_contains "$plan" "ext|/path/to/ext.srt|ita|1|srt|0"
}

test_plan_default_marking() {
  export MARK_NORMAL_SUB_DEFAULT=1
  
  probe_internal_subs() {
    echo "0|subrip|eng|English|0|0|0"
  }
  
  discover_external_subs() {
    echo ""
  }
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # Expect is_default=1 (last column)
  assert_contains "$plan" "int|0|eng|0|subrip|1"
}

test_plan_scoring_preference() {
  # 1. External Eng Normal (text)
  # 2. Internal Eng Normal (pgs/bitmap)
  # External text should win over Internal bitmap for the "Normal English" slot.
  
  probe_internal_subs() {
    echo "0|hdmv_pgs_subtitle|eng|English PGS|0|0|0"
  }
  
  discover_external_subs() {
    echo "/ext/eng.srt|eng|0|0|0|srt"
  }
  
  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"
  
  # External should be chosen for Eng Normal slot
  # Internal PGS should be dropped (because we only keep 1 normal eng)
  
  assert_contains "$plan" "ext|/ext/eng.srt|eng|0|srt|0"
  assert_not_contains "$plan" "int|0|eng|0|hdmv_pgs_subtitle|0"
}
