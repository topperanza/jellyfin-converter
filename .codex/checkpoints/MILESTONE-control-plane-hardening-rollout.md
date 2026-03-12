# Milestone control-plane-hardening-rollout

## Goal
Apply hardened Codex control-plane baseline with minimal repo-native changes: executable conformance check, workflow versioning, canonical prompt-path consistency, and release-flow discoverability retention.

## Files changed
- `scripts/codex/check-workflow-conformance.sh`
- `scripts/codex/setup.sh`
- `scripts/codex/maintenance.sh`
- `docs/codex/WORKFLOW_VERSION.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/usage-prompts/0000-README-usage-order.md`
- `docs/codex/STATUS.md`
- `.codex/checkpoints/MILESTONE-control-plane-hardening-rollout.md`

## Commands run
- `bash scripts/codex/check-workflow-conformance.sh`
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`

## Results
- Pass: conformance script validates required control-plane files, canonical prompt directory, release-flow prompts, and anti-loop scope guards.
- Pass: fast validation (`bash -n`, parser suite, self-check) passed.
- Pass: changed-file checks passed and included Bash 3.2 compatibility check.

## Risks / follow-ups
- `bash scripts/check-full.sh` was not run for this docs/control-plane rollout; run it in a later broader runtime milestone if conversion logic changes.
