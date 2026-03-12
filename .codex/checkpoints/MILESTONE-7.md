# MILESTONE-7 — Final prompt-pack baseline migration verification

## Goal and completion criteria
- Goal: apply one-time verification that the repository is already on the final Codex prompt-pack/control-plane baseline with minimal diff.
- Completion criteria:
  - canonical prompt-pack path remains `docs/codex/usage-prompts`
  - final expected prompt file set is present
  - stale temporary/legacy prompt references are not active in control-plane docs
  - conformance + fast + changed validation pass

## Files changed
- `docs/codex/PLAN.md`
- `docs/codex/WORKFLOW_VERSION.md`
- `docs/codex/STATUS.md`
- `.codex/checkpoints/MILESTONE-7.md`

## Commands run
- `test -d docs/codex/usage-prompts`
- prompt-file existence loop over final expected baseline
- `rg -n "docs/codex/usage-prompts/(00-README-usage-order\.md|07-commit-push-after-pass\.md|08-full-repo-audit-recovery\.md|09-release-prep\.md|1[0-9]-.*\.md)" README.md AGENTS.md docs/codex scripts .codex/checkpoints/README.md`
- `bash scripts/codex/check-workflow-conformance.sh`
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`

## Results
- Pass: canonical prompt-pack path and final expected prompt file baseline verified.
- Pass: no stale legacy prompt references found in active control-plane docs.
- Pass: `bash scripts/codex/check-workflow-conformance.sh`.
- Pass: `bash scripts/check-fast.sh`.
- Pass: `bash scripts/check-changed.sh HEAD~1`.
- Not run (not justified for docs/control-plane migration-only scope): `bash scripts/check-full.sh`.

## Risks and next step
- Risk: none identified for runtime behavior (no converter logic changed).
- Next step: proceed with next numbered runtime milestone from `docs/codex/PLAN.md` when scheduled.
