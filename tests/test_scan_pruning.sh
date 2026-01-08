#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="$ROOT/scripts/jellyfin_converter.sh"

TMP_ROOT="$(mktemp -d)"
WORKDIR="$TMP_ROOT/workdir"
STUB_BIN="$TMP_ROOT/bin"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$WORKDIR" "$STUB_BIN"

# Create dummy binaries
cat >"$STUB_BIN/ffmpeg" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$STUB_BIN/ffprobe" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$STUB_BIN/ffmpeg" "$STUB_BIN/ffprobe"

export PATH="$STUB_BIN:$PATH"

# Setup fixture tree
mkdir -p "$WORKDIR/input"
mkdir -p "$WORKDIR/input/.hidden"
mkdir -p "$WORKDIR/input/converted"
mkdir -p "$WORKDIR/input/logs"

touch "$WORKDIR/input/movie.mkv"
touch "$WORKDIR/input/.hidden/hidden_movie.mkv"
touch "$WORKDIR/input/converted/generated_movie.mkv"

# Function to run the converter
run_converter() {
  local include_hidden="${1:-0}"
  local output_file="$TMP_ROOT/output.txt"
  
  INCLUDE_HIDDEN="$include_hidden" \
  DRY_RUN=1 \
  DELETE=0 \
  SKIP_DELETE_CONFIRM=1 \
  OUTROOT="converted" \
  "$SCRIPT_PATH" "$WORKDIR/input" >"$output_file" 2>&1
  
  cat "$output_file"
}

test_default_pruning() {
  echo "Testing default pruning (should exclude hidden and output)..."
  local output
  output="$(run_converter 0)"
  
  if echo "$output" | grep -q "movie.mkv"; then
    echo "PASS: Found normal movie"
  else
    echo "FAIL: Did not find normal movie"
    exit 1
  fi

  if echo "$output" | grep -q "hidden_movie.mkv"; then
    echo "FAIL: Found hidden movie (should be pruned)"
    exit 1
  else
    echo "PASS: Hidden movie pruned"
  fi

  if echo "$output" | grep -q "generated_movie.mkv"; then
    echo "FAIL: Found output movie (should be pruned)"
    exit 1
  else
    echo "PASS: Output movie pruned"
  fi
}

test_include_hidden() {
  echo "Testing INCLUDE_HIDDEN=1 (should include hidden, exclude output)..."
  local output
  output="$(run_converter 1)"
  
  if echo "$output" | grep -q "hidden_movie.mkv"; then
    echo "PASS: Found hidden movie"
  else
    echo "FAIL: Did not find hidden movie"
    exit 1
  fi
  
  if echo "$output" | grep -q "generated_movie.mkv"; then
    echo "FAIL: Found output movie (should be pruned)"
    exit 1
  else
    echo "PASS: Output movie pruned"
  fi
}

# Run tests only if executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  test_default_pruning
  test_include_hidden
  echo "All scan pruning tests passed!"
fi
