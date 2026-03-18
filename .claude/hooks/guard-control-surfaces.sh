#!/usr/bin/env bash
# PreToolUse hook: block unintentional modification of protected local control surfaces.
#
# Protected surfaces:
#   .claude/settings.local.json  — machine-local Claude overrides (gitignored)
#   .claude/settings.json        — project-level Claude policy (tracked)
#   .git/info/exclude            — local gitignore workaround surface
#
# Exit 1 = deny the tool call with a message on stderr.
# Exit 0 = allow the tool call to proceed.

PROTECTED=(
  ".claude/settings.local.json"
  ".claude/settings.json"
  ".git/info/exclude"
  ".claude/hooks/guard-control-surfaces.sh"
)

INPUT=$(cat)

# Extract tool name
TOOL=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('tool_name', ''))
except Exception:
    print('')
" 2>/dev/null)

case "$TOOL" in
  Write|Edit|MultiEdit)
    TARGET=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null)
    ;;
  Bash)
    TARGET=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null)
    ;;
  *)
    exit 0
    ;;
esac

for p in "${PROTECTED[@]}"; do
  if [[ "$TARGET" == *"$p"* ]]; then
    echo "BLOCKED: '$p' is a protected control surface. Modify it manually if this is intentional." >&2
    exit 1
  fi
done

exit 0
