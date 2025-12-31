#!/usr/bin/env bash

# Setup: Source the library to be tested
setup() {
  # Assume we are running from project root
  source "scripts/lib/media_filters.sh"
}

test_map_lang_basic() {
  assert_eq "eng" "$(map_lang "English")" "English -> eng"
  assert_eq "ita" "$(map_lang "Italian")" "Italian -> ita"
  assert_eq "eng" "$(map_lang "en")" "en -> eng"
}

test_map_lang_complex() {
  assert_eq "por" "$(map_lang "pt-br")" "pt-br -> por"
  assert_eq "zho" "$(map_lang "chi")" "chi -> zho"
  assert_eq "" "$(map_lang "unknown_lang_xyz")" "unknown -> empty"
}

test_is_eng_or_ita() {
  if is_eng_or_ita "eng"; then
    true
  else
    fail "eng should be eng_or_ita"
  fi
  
  if is_eng_or_ita "ita"; then
    true
  else
    fail "ita should be eng_or_ita"
  fi
  
  if is_eng_or_ita "rus"; then
    fail "rus is NOT eng_or_ita"
  fi
}

test_is_commentary_title() {
  if is_commentary_title "Director's Commentary"; then
    true
  else
    fail "Director's Commentary should be commentary"
  fi
  
  if is_commentary_title "Main Audio"; then
    fail "Main Audio is NOT commentary"
  fi

  if is_commentary_title "Commento al regista"; then
    true
  else
    fail "Commento al regista (ita) should be commentary"
  fi
}
