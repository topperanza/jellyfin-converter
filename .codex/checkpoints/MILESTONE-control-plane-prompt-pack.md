# Milestone control-plane-prompt-pack: final control-plane closure tracking
- Date: 2026-03-11
- Goal: close control-plane patch tracking for RUNBOOK routing, cloud checklist, and usage-prompts pack with fresh validation evidence.
- Completion criteria: STATUS and checkpoint are aligned for this closure, and required re-validation commands pass.

## Files changed
- `docs/codex/RUNBOOK.md`
- `docs/codex/CLOUD_ENV_CHECKLIST.md`
- `docs/codex/usage-prompts/00-README-usage-order.md`
- `docs/codex/usage-prompts/01-next-milestone-planner.md`
- `docs/codex/usage-prompts/02-milestone-implementation.md`
- `docs/codex/usage-prompts/03-milestone-gate.md`
- `docs/codex/usage-prompts/04-blocker-patch.md`
- `docs/codex/usage-prompts/05-blocker-closure-check.md`
- `docs/codex/usage-prompts/06-final-local-verification.md`
- `docs/codex/usage-prompts/07-commit-push-after-pass.md`
- `docs/codex/usage-prompts/08-full-repo-audit-recovery.md`
- `docs/codex/usage-prompts/09-release-prep.md`
- `docs/codex/STATUS.md`
- `.codex/checkpoints/MILESTONE-control-plane-prompt-pack.md`


## Legacy naming note (historical context)
- This checkpoint predates prompt-pack filename normalization completed in `MILESTONE-control-plane-hardening-rollout`.
- The prompt filenames listed in this file are historical names from that run and are retained for audit history only.
- Canonical prompt filenames and routing are enforced by `scripts/codex/check-workflow-conformance.sh` and documented in `docs/codex/WORKFLOW_VERSION.md`.

## Commands run
- Historical closure evidence:
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
  - `bash scripts/check-full.sh`
- Current closure re-validation:
  - `expected='00-README-usage-order.md ... 09-release-prep.md'; actual="$(find docs/codex/usage-prompts -maxdepth 1 -type f -exec basename {} \; | sort)"; [ "$expected" = "$actual" ]; for f in docs/codex/usage-prompts/*.md; do rg -q '^# ' "$f"; rg -q '^When to use:' "$f"; rg -q '^Run in:' "$f"; rg -q '^```text' "$f"; done`
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`

## Results
- Pass: usage-prompts filename + structure validation command.
- Pass: `bash scripts/check-fast.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- STATUS/checkpoint tracking now reflects this control-plane closure.

## Risks / next step
- Risk: none identified for this documentation-only closure.
- Next step: proceed with commit/push prompt execution.
