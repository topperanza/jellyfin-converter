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
  export MARK_NORMAL_SUB_DEFAULT=0
  export KEEP_BITMAP_SUBS=0
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

test_plan_scoring_external_bitmap_vs_internal_text() {
  export KEEP_BITMAP_SUBS=1

  probe_internal_subs() {
    echo "0|subrip|eng|English|0|0|0"
  }

  discover_external_subs() {
    echo "/ext/eng.sup|eng|0|0|0|sup"
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  # Internal text should win over external bitmap
  assert_contains "$plan" "int|0|eng|0|subrip|0"
  assert_not_contains "$plan" "ext|/ext/eng.sup|eng|0|sup|0"
}

test_plan_prefers_default_normal_track() {
  local input
  input="$(cat tests/fixtures/eng_default_vs_nondefault.txt)"

  probe_internal_subs() {
    echo "$input"
  }

  discover_external_subs() {
    echo ""
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  assert_contains "$plan" "int|1|eng|0|subrip|0"
  assert_not_contains "$plan" "int|0|eng|0|subrip|0"
}

test_plan_prefers_text_over_bitmap_for_same_slot() {
  local input
  input="$(cat tests/fixtures/eng_text_vs_bitmap.txt)"

  probe_internal_subs() {
    echo "$input"
  }

  discover_external_subs() {
    echo ""
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  assert_contains "$plan" "int|1|eng|0|subrip|0"
  assert_not_contains "$plan" "int|0|eng|0|hdmv_pgs_subtitle|0"
}

test_plan_keeps_eng_forced_and_normal_slots() {
  local input
  input="$(cat tests/fixtures/eng_forced_and_normal.txt)"

  probe_internal_subs() {
    echo "$input"
  }

  discover_external_subs() {
    echo ""
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  assert_contains "$plan" "int|0|eng|1|subrip|0"
  assert_contains "$plan" "int|1|eng|0|subrip|0"
}

test_plan_prefers_default_within_forced_slot() {
  local input
  input=$'0|subrip|eng|English forced alt|0|1|0\n1|subrip|eng|English forced default|1|1|0\n2|subrip|eng|English normal|0|0|0'

  probe_internal_subs() {
    echo "$input"
  }

  discover_external_subs() {
    echo ""
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  assert_contains "$plan" "int|1|eng|1|subrip|0"
  assert_not_contains "$plan" "int|0|eng|1|subrip|0"
  assert_contains "$plan" "int|2|eng|0|subrip|0"
}

test_plan_external_bitmap_ignored_when_keep0() {
  export KEEP_BITMAP_SUBS=0

  probe_internal_subs() {
    echo ""
  }

  discover_external_subs() {
    echo "/ext/eng.sup|eng|0|0|0|sup"
  }

  local plan
  plan="$(build_subtitle_plan "dummy.mkv")"

  assert_eq "" "$plan" "Expected empty plan when KEEP_BITMAP_SUBS=0"
}

test_plan_real_ffprobe_fallback_keeps_forced_subtitle() (
  if ! type -P ffmpeg >/dev/null || ! type -P ffprobe >/dev/null; then
    echo "SKIP: real subtitle fallback requires ffmpeg and ffprobe"
    return 0
  fi

  # Use the real ffprobe and the discovery function from the module.
  unset -f ffprobe
  source "scripts/lib/media_filters.sh"

  local tmp fixture raw video_probe plan
  tmp="$(mktemp -d)" || fail "Could not create fixture directory"
  trap 'rm -rf "$tmp"' EXIT
  fixture="$tmp/sample.mkv"
  printf '1\n00:00:00,000 --> 00:00:00,800\nSynthetic subtitle\n' >"$tmp/caption.srt"
  command ffmpeg -nostdin -v error -f lavfi -i 'color=s=32x32:r=1:d=1' \
    -i "$tmp/caption.srt" -map 0:v -map 1:s -map 1:s -map 1:s \
    -c:v mpeg4 -c:s srt \
    -metadata:s:s:0 language=eng -metadata:s:s:0 'title=English, main = primary' \
    -metadata:s:s:1 language=rus -metadata:s:s:2 language=rus \
    -disposition:s:0 default+hearing_impaired -disposition:s:1 forced -disposition:s:2 0 \
    "$fixture" || fail "Could not mux synthetic subtitle fixture"

  local SUB_LANGS=eng,ita
  raw="$(probe_internal_subs "$fixture")"
  assert_eq $'1|subrip|eng|English, main = primary|1|0|1\n2|subrip|rus||0|1|0\n3|subrip|rus||0|0|0' "$raw"

  local expected_plan=$'int|1|eng|0|subrip|0\nint|2|rus|1|subrip|0'
  plan="$(build_subtitle_plan "$fixture")" || fail "Fallback with no batched data failed"
  assert_eq "$expected_plan" "$plan"

  video_probe="$(command ffprobe -v error -select_streams v -show_streams -of flat "$fixture")" ||
    fail "Could not probe synthetic video stream"
  assert_contains "$video_probe" 'codec_type="video"'
  plan="$(build_subtitle_plan "$fixture" "$video_probe")" || fail "Fallback with video-only batched data failed"
  assert_eq "$expected_plan" "$plan"
)
