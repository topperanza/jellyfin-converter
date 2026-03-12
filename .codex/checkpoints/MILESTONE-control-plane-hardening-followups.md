# Milestone control-plane-hardening-followups
- Date: 2026-03-12
- Goal: close follow-up hardening actions by adding CI conformance gating, clarifying legacy prompt-name checkpoint context, and tightening prompt-pack schema checks.
- Completion criteria: CI hard-gates conformance script, legacy checkpoint context is explicit, and conformance script validates canonical prompt-pack filename schema.

## Files changed
- `.github/workflows/ci.yml`
- `scripts/codex/check-workflow-conformance.sh`
- `.codex/checkpoints/MILESTONE-control-plane-prompt-pack.md`
- `.codex/checkpoints/MILESTONE-control-plane-hardening-followups.md`
- `docs/codex/STATUS.md`

## Commands run
- `bash scripts/codex/check-workflow-conformance.sh`
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`

## Results
- Pass: CI now includes explicit hard-gate step for `bash scripts/codex/check-workflow-conformance.sh`.
- Pass: conformance script now verifies canonical prompt-pack filename/schema set.
- Pass: legacy checkpoint has explicit historical naming annotation.

## Risks / next step
- `bash scripts/check-full.sh` not run (docs/control-plane + CI wiring scope only; no converter runtime behavior change).
- Next step: run broader full validation in next runtime-affecting milestone.
