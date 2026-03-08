#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

run() {
  echo "+ $*"
  "$@"
}

run bash scripts/check-fast.sh
run ./tests/run.sh
run bash scripts/check_bash32.sh
