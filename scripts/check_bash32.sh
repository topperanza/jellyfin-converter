#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

status=0
pattern='(^|[^[:alnum:]_])(local[[:space:]]+-n|declare[[:space:]]+-A|mapfile|readarray)($|[^[:alnum:]_])'

while IFS= read -r file; do
  [[ "$file" == "scripts/check_bash32.sh" ]] && continue
  if grep -En "$pattern" "$file" >/dev/null 2>&1; then
    echo "Bash 3.2 compatibility violation in $file:"
    grep -En "$pattern" "$file"
    status=1
  fi
done < <(find scripts tests release -type f -name "*.sh" -print)

if [[ -f "install.sh" ]] && grep -En "$pattern" "install.sh" >/dev/null 2>&1; then
  echo "Bash 3.2 compatibility violation in install.sh:"
  grep -En "$pattern" "install.sh"
  status=1
fi

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "Bash 3.2 compatibility check passed."
