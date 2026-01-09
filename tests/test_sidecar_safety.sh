#!/usr/bin/env bash
set -euo pipefail

# Setup environment
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/compat.sh
source "$SCRIPT_DIR/scripts/lib/compat.sh"
# shellcheck source=scripts/lib/media_filters.sh
source "$SCRIPT_DIR/scripts/lib/media_filters.sh"
# shellcheck source=scripts/lib/process.sh
source "$SCRIPT_DIR/scripts/lib/process.sh"

# Mock VIDEO_FORMATS
VIDEO_FORMATS="avi|mp4|mov|wmv|flv|m4v|mpg|mpeg|vob|ts|m2ts|webm|asf|divx|3gp|ogv|mkv"

# Setup temp dir
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "FAIL: $1"
  exit 1
}

test_delete_sidecars_off() {
  echo "Test: DELETE_SIDECARS=0 (default)"
  touch "$TMP_DIR/movie_off.mkv"
  touch "$TMP_DIR/movie_off.srt"
  
  DELETE_SIDECARS=0
  if is_sidecar_safe_to_delete "$TMP_DIR/movie_off.srt" "$TMP_DIR/movie_off.mkv"; then
    fail "Should not be safe when DELETE_SIDECARS=0"
  fi
  echo "PASS"
}

test_unique_sidecar() {
  echo "Test: Unique sidecar"
  touch "$TMP_DIR/unique.mkv"
  touch "$TMP_DIR/unique.srt"
  
  DELETE_SIDECARS=1
  if ! is_sidecar_safe_to_delete "$TMP_DIR/unique.srt" "$TMP_DIR/unique.mkv"; then
    fail "Should be safe when unique and DELETE_SIDECARS=1"
  fi
  echo "PASS"
}

test_ambiguous_sidecar() {
  echo "Test: Ambiguous sidecar (shared by another video)"
  touch "$TMP_DIR/shared.mp4"
  touch "$TMP_DIR/shared.mkv"
  touch "$TMP_DIR/shared.srt"
  
  DELETE_SIDECARS=1
  
  # shared.srt matches shared.mp4 AND shared.mkv
  
  # Check from perspective of shared.mp4
  if is_sidecar_safe_to_delete "$TMP_DIR/shared.srt" "$TMP_DIR/shared.mp4"; then
    fail "Should NOT be safe: shared.srt matches shared.mkv too"
  fi
  
  # Check from perspective of shared.mkv
  if is_sidecar_safe_to_delete "$TMP_DIR/shared.srt" "$TMP_DIR/shared.mkv"; then
     fail "Should NOT be safe: shared.srt matches shared.mp4 too"
  fi
  
  echo "PASS"
}

test_partial_match_safety() {
  echo "Test: Partial match safety"
  # movie.mp4
  # movie.part1.mp4
  # movie.part1.srt
  
  touch "$TMP_DIR/movie.mp4"
  touch "$TMP_DIR/movie.part1.mp4"
  touch "$TMP_DIR/movie.part1.srt"
  
  DELETE_SIDECARS=1
  
  # movie.part1.srt belongs to movie.part1.mp4
  # But movie.mp4 MIGHT claim it via discover_external_subs logic?
  # discover_external_subs logic:
  # base="movie"
  # stem="movie.part1"
  # stem starts with base? Yes.
  # next char is "."? Yes.
  # So movie.mp4 matches movie.part1.srt.
  
  # So if we process movie.mp4, and it considers deleting movie.part1.srt...
  # It should check if movie.part1.srt is claimed by movie.part1.mp4.
  
  # is_sidecar_safe_to_delete(sidecar, current_video)
  # is_sidecar_safe_to_delete("$TMP_DIR/movie.part1.srt", "$TMP_DIR/movie.mp4")
  
  # It checks other videos in dir: movie.part1.mp4
  # Does movie.part1.mp4 match movie.part1.srt?
  # base="movie.part1", stem="movie.part1". Match!
  
  # So it should be unsafe.
  
  if is_sidecar_safe_to_delete "$TMP_DIR/movie.part1.srt" "$TMP_DIR/movie.mp4"; then
     fail "Should NOT be safe: movie.part1.srt matches movie.part1.mp4"
  fi
  
  echo "PASS"
}

# Run tests
test_delete_sidecars_off
test_unique_sidecar
test_ambiguous_sidecar
test_partial_match_safety

echo "ALL TESTS PASSED"
