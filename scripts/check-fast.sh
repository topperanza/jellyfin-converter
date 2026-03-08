#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

run() {
  echo "+ $*"
  "$@"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run bash -n scripts/jellyfin_converter.sh
run ./tests/run.sh tests/suite_parser.sh

if need_cmd ffmpeg && need_cmd ffprobe; then
  run ./run.sh --self-check
else
  echo "SKIP: ./run.sh --self-check (ffmpeg/ffprobe unavailable)"
fi
