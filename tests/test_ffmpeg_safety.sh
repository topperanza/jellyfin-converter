#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVERTER="$SCRIPT_DIR/scripts/jellyfin_converter.sh"
FFMPEG_LIB="$SCRIPT_DIR/scripts/lib/ffmpeg.sh"

echo "Testing ffmpeg safety in $CONVERTER..."

# 1. Check for absence of unsafe grep pipe
if grep -F 'grep -v "Timestamps are unset"' "$CONVERTER"; then
  echo "FAIL: Found unsafe grep pipe in jellyfin_converter.sh"
  exit 1
else
  echo "PASS: Unsafe grep pipe removed"
fi

# 2. Check for presence of run_ffmpeg in lib
if ! grep -q "run_ffmpeg()" "$FFMPEG_LIB"; then
  echo "FAIL: run_ffmpeg wrapper not found in ffmpeg.sh"
  exit 1
else
  echo "PASS: run_ffmpeg wrapper defined"
fi

# 3. Check for usage of run_ffmpeg in converter
if ! grep -q "run_ffmpeg" "$CONVERTER"; then
  echo "FAIL: run_ffmpeg not used in jellyfin_converter.sh"
  exit 1
else
  echo "PASS: run_ffmpeg is being used"
fi

echo "All safety checks passed."
