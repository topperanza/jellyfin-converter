#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$ROOT/VERSION" ]]; then
  echo "release: VERSION file missing; cannot determine expected version"
  exit 1
fi

required_version="$(cat "$ROOT/VERSION")"

for bin in ffmpeg ffprobe find df; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "release: '$bin' is required for version check and must be on PATH (install via homebrew or pkg manager)"
    exit 1
  fi
done

script_version="$("$ROOT/run.sh" --version | awk '{print $2}')"
file_version="$required_version"

if [[ "$script_version" != "$required_version" || "$file_version" != "$required_version" ]]; then
  echo "release: Version mismatch: script=$script_version file=$file_version expected=$required_version"
  exit 1
fi

echo "Release check: version verified via run.sh --version (uses ffmpeg/ffprobe/find/df on PATH)"
echo "Running smoke test (uses stubbed binaries; no user data touched)..."
"$ROOT/tests/test_smoke.sh"

echo "READY TO RELEASE v$required_version"
