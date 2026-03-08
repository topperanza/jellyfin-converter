#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

run() {
  echo "+ $*"
  "$@"
}

if ! command -v git >/dev/null 2>&1; then
  echo "SKIP: git not available"
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "SKIP: not in a git work tree"
  exit 0
fi

base_ref="${1:-HEAD}"
changed_files="$(git diff --name-only "$base_ref" --)"

if [[ -z "$changed_files" ]]; then
  echo "No changed files detected against $base_ref"
  exit 0
fi

needs_shell=0
needs_tests=0
needs_bash32=0

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  case "$file" in
    scripts/*.sh|tests/*.sh|run.sh|install.sh|release/*.sh)
      needs_shell=1
      ;;
  esac

  case "$file" in
    scripts/jellyfin_converter.sh|scripts/lib/*|tests/*|run.sh)
      needs_tests=1
      ;;
  esac

  case "$file" in
    scripts/*.sh|tests/*.sh|install.sh|release/*.sh)
      needs_bash32=1
      ;;
  esac
done <<EOF_FILES
$changed_files
EOF_FILES

if [[ "$needs_shell" -eq 1 ]]; then
  run bash -n scripts/jellyfin_converter.sh
fi

if [[ "$needs_tests" -eq 1 ]]; then
  run ./tests/run.sh tests/suite_parser.sh
fi

if [[ "$needs_bash32" -eq 1 ]]; then
  run bash scripts/check_bash32.sh
fi

echo "Changed-file checks completed against $base_ref"
