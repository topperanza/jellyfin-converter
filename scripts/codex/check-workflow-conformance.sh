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

echo "==> Codex workflow conformance"
echo "CODEX_DOCS_DIR=$CODEX_DOCS_DIR"
echo "PROMPTS_DIR=$PROMPTS_DIR"

[[ -d "$CODEX_DOCS_DIR" ]] || fail "missing directory: $CODEX_DOCS_DIR"
[[ -d "$PROMPTS_DIR" ]] || fail "missing directory: $PROMPTS_DIR"

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

rg -q '^# Codex Workflow Version' "$CODEX_DOCS_DIR/WORKFLOW_VERSION.md" || fail "workflow version header missing"
rg -q '^\- Current workflow version:' "$CODEX_DOCS_DIR/WORKFLOW_VERSION.md" || fail "workflow version value missing"

rg -q 'Milestone completion is determined by the milestone contract plus the blocking rules' "$CODEX_DOCS_DIR/RUNBOOK.md" || fail "runbook missing contract-scoped gate rule"
rg -q 'downstream sync surface' "$CODEX_DOCS_DIR/DOC_SYNC_MATRIX.md" || fail "DOC_SYNC_MATRIX missing downstream export rule"

rg -q 'release-prep review' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing release-prep step"
rg -q 'tag \+ release' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing tag+release step"
rg -q 'Full repo audit is recovery-only' "$PROMPTS_DIR/0000-README-usage-order.md" || fail "prompt index missing recovery-only audit guardrail"
rg -q 'This is a blocker-closure check, not a fresh milestone gate and not a full repo audit' "$PROMPTS_DIR/05-blocker-closure-check.md" || fail "blocker-closure scope guardrail missing"

echo "Conformance checks passed"
