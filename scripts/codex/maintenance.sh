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
chmod +x run.sh scripts/jellyfin_converter.sh tests/run.sh scripts/codex/setup.sh scripts/codex/maintenance.sh scripts/check-fast.sh scripts/check-full.sh scripts/check-changed.sh 2>/dev/null || true

echo "==> Maintenance sanity checks"
if [[ -x scripts/check-fast.sh ]]; then
  echo "bash scripts/check-fast.sh"
  bash scripts/check-fast.sh
else
  echo "bash -n scripts/jellyfin_converter.sh"
  bash -n scripts/jellyfin_converter.sh
fi

echo "Maintenance completed"
