#!/usr/bin/env bash

setup() {
  source "scripts/lib/media_filters.sh"
}

test_discovery_case1_simple() {
  local video="tests/fixtures/discovery/case1/movie.mkv"
  local output
  output="$(discover_external_subs "$video")"
  
  # Expected:
  # movie.eng.srt -> eng|0|0|0|srt
  # movie.ita.forced.srt -> ita|1|0|0|srt
  # movie.rus.ass -> rus|0|0|0|ass
  
  assert_contains "$output" "movie.eng.srt|eng|0|0|0|srt"
  assert_contains "$output" "movie.ita.forced.srt|ita|1|0|0|srt"
  assert_contains "$output" "movie.rus.ass|rus|0|0|0|ass"
}

test_discovery_case2_dots() {
  local video="tests/fixtures/discovery/case2/show.S01E01.mkv"
  local output
  output="$(discover_external_subs "$video")"
  
  # Expected:
  # show.S01E01.en.srt -> eng|0|0|0|srt
  # show.S01E01.en.sdh.srt -> eng|0|1|0|srt
  # show.S01E01.commentary.srt -> und|0|0|1|srt
  
  # NOTE: discover_external_subs deduplicates by lang|forced.
  # en.srt (eng|0) and en.sdh.srt (eng|0) collide.
  # With PREFER_SDH=0 (default), en.srt wins.
  
  assert_contains "$output" "show.S01E01.en.srt|eng|0|0|0|srt"
  assert_not_contains "$output" "show.S01E01.en.sdh.srt"
  
  # Commentary should be preserved (it's separate category? No, check key)
  # Commentary logic:
  # In discover_external_subs loop: lang="" -> und. forced=0.
  # Key: und|0.
  # If there are multiple und|0, only one survives.
  # commentary.srt -> und|0|0|1|srt.
  # Is there another und|0? No.
  
  assert_contains "$output" "show.S01E01.commentary.srt|und|0|0|1|srt"
}

test_discovery_case3_complex_tokens() {
  local video="tests/fixtures/discovery/case3_complex/film.mkv"
  local output
  output="$(discover_external_subs "$video")"
  
  # film.eng (forced).srt -> eng|1|0|0|srt
  # film.ita.[default].srt -> ita|0|0|0|srt (default is not parsed by discovery, only forced/sdh/commentary)
  
  assert_contains "$output" "film.eng (forced).srt|eng|1|0|0|srt"
  assert_contains "$output" "film.ita.[default].srt|ita|0|0|0|srt"
}
