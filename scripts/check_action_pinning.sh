#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

while IFS= read -r file; do
  while IFS= read -r line; do
    ref="${line#*uses: }"
    ref="${ref%%#*}"
    ref="${ref%%[[:space:]]*}"
    [[ "$ref" != *"@"* ]] && continue
    action="${ref%@*}"
    tag="${ref##*@}"

    if [[ "$action" == ./* ]]; then
      continue
    fi

    if [[ ! "$tag" =~ ^[0-9a-f]{40}$ ]]; then
      echo "ERROR: action not pinned to SHA in $file"
      echo "  $line"
      status=1
    fi
  done < <(grep -E '^[[:space:]]*uses:' "$file" || true)
done < <(find "$ROOT/.github/workflows" -type f -name '*.yml' -print)

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "Action pinning check passed"
