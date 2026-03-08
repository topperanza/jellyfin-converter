#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

if [[ -f .codex/env.sh ]]; then
  # shellcheck source=/dev/null
  . .codex/env.sh
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

mkdir -p .codex/checkpoints

# Keep executable bits in place for cached/resumed containers.
chmod +x run.sh scripts/jellyfin_converter.sh tests/run.sh scripts/codex/setup.sh scripts/codex/maintenance.sh 2>/dev/null || true

echo "==> Maintenance sanity checks"
echo "bash -n scripts/jellyfin_converter.sh"
bash -n scripts/jellyfin_converter.sh

if need_cmd ffmpeg && need_cmd ffprobe; then
  echo "./run.sh --self-check"
  ./run.sh --self-check >/dev/null
else
  echo "SKIP: ./run.sh --self-check (ffmpeg/ffprobe unavailable)"
  echo "Hint: run bash scripts/codex/setup.sh when package network access is available"
fi

echo "Maintenance completed"
