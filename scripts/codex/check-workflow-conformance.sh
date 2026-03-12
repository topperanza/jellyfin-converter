#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

CODEX_DOCS_DIR="docs/codex"
PROMPTS_DIR="$CODEX_DOCS_DIR/usage-prompts"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

need_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing required file: $path"
}

need_pattern() {
  local pattern="$1"
  local path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$path"
  else
    grep -Eq "$pattern" "$path"
  fi
}


echo "==> Codex workflow conformance"
echo "CODEX_DOCS_DIR=$CODEX_DOCS_DIR"
echo "PROMPTS_DIR=$PROMPTS_DIR"

[[ -d "$CODEX_DOCS_DIR" ]] || fail "missing directory: $CODEX_DOCS_DIR"
[[ -d "$PROMPTS_DIR" ]] || fail "missing directory: $PROMPTS_DIR"


expected_prompt_files=(
  00-repo-starter.md
  000-full-repo-audit-recovery-only.md
  0000-README-usage-order.md
  01-next-milestone-planner.md
  02-milestone-implementation.md
  03-milestone-gate.md
  04-blocker-patch.md
  05-blocker-closure-check.md
  06-final-local-verification.md
  07-commit-and-push-after-pass.md
  08-release-prep.md
  09-tag-and-release.md
)

actual_prompt_files=()
while IFS= read -r file; do
  actual_prompt_files+=("$file")
done < <(find "$PROMPTS_DIR" -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort)

if [[ "${expected_prompt_files[*]}" != "${actual_prompt_files[*]}" ]]; then
  echo "Expected prompt files:" >&2
  printf '  %s\n' "${expected_prompt_files[@]}" >&2
  echo "Actual prompt files:" >&2
  printf '  %s\n' "${actual_prompt_files[@]}" >&2
  fail "prompt-pack filename/schema mismatch under $PROMPTS_DIR"
fi

need_file "$CODEX_DOCS_DIR/PLAN.md"
need_file "$CODEX_DOCS_DIR/STATUS.md"
need_file "$CODEX_DOCS_DIR/RUNBOOK.md"
need_file "$CODEX_DOCS_DIR/DOC_SYNC_MATRIX.md"
need_file "$CODEX_DOCS_DIR/CLOUD_ENV_CHECKLIST.md"
need_file "$CODEX_DOCS_DIR/WORKFLOW_VERSION.md"

need_file "$PROMPTS_DIR/0000-README-usage-order.md"
need_file "$PROMPTS_DIR/000-full-repo-audit-recovery-only.md"
need_file "$PROMPTS_DIR/05-blocker-closure-check.md"
need_file "$PROMPTS_DIR/08-release-prep.md"
need_file "$PROMPTS_DIR/09-tag-and-release.md"

if [[ -d "$CODEX_DOCS_DIR/prompts" ]]; then
  fail "non-canonical prompts directory detected: $CODEX_DOCS_DIR/prompts"
fi

need_pattern '^# Codex Workflow Version' "$CODEX_DOCS_DIR/WORKFLOW_VERSION.md" || fail "workflow version header missing"
need_pattern '^\- Current workflow version:' "$CODEX_DOCS_DIR/WORKFLOW_VERSION.md" || fail "workflow version value missing"

need_pattern 'Milestone completion is determined by the milestone contract plus the blocking rules' "$CODEX_DOCS_DIR/RUNBOOK.md" || fail "runbook missing contract-scoped gate rule"
need_pattern 'downstream sync surface' "$CODEX_DOCS_DIR/DOC_SYNC_MATRIX.md" || fail "DOC_SYNC_MATRIX missing downstream export rule"

need_pattern 'release-prep review' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing release-prep step"
need_pattern 'tag \+ release' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing tag+release step"
need_pattern 'Full repo audit is recovery-only' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing recovery-only audit guardrail"
need_pattern 'This is a blocker-closure check, not a fresh milestone gate and not a full repo audit' "$PROMPTS_DIR/05-blocker-closure-check.md" || fail "blocker-closure scope guardrail missing"

echo "Conformance checks passed"
