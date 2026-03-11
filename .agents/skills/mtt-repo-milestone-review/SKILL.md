---
name: mtt-repo-milestone-review
description: Use this skill when you need a milestone gate decision for the active plan milestone (or a release-facing truth audit) based on actual repo state. Do not use for planning the next milestone or for docs/project-files-only sync checks.
---

# mtt-repo-milestone-review

## Trigger when
- You need to infer the real active milestone from `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/REPO_OVERVIEW.md`, `docs/codex/DOC_SYNC_MATRIX.md`, and changed code/tests/docs.
- You need a gate result for milestone completion against the milestone contract plus DOC_SYNC_MATRIX blocking rules.
- You need issue classification as `BLOCKING` vs `NON-BLOCKING FOLLOW-UP`.
- You need review emphasis on conversion truth: deterministic ffmpeg behavior, originals safety, stream mapping, output naming/metadata correctness, validation evidence, and operator-facing docs.

## Do not trigger when
- You only need to plan the next milestone (`mtt-next-milestone-planner`).
- You only need to audit `docs/project-files/` export readiness (`mtt-project-files-sync-audit`).
- You are only preparing commit/push bookkeeping (`mtt-commit-push-tracker`).

## Procedure
1. Identify milestone contract in `docs/codex/PLAN.md` and current progress in `docs/codex/STATUS.md`.
2. Verify changed areas against repo truth surfaces (code/tests/config/docs).
3. Apply gate rule: milestone passes only if PLAN contract and all DOC_SYNC_MATRIX blocking rows for the change type are satisfied.
4. Record findings in two sections:
   - `BLOCKING`
   - `NON-BLOCKING FOLLOW-UP`
5. Return one explicit verdict:
   - `MILESTONE GATE: PASS`
   - `MILESTONE GATE: FAIL`
6. If PASS, include `SAFE TO MOVE ON` and list any non-blocking follow-ups.

## Output format
- Active milestone inferred
- Evidence checked (files + validations)
- Blocking findings
- Non-blocking follow-ups
- Final verdict (`PASS`/`FAIL`, plus `SAFE TO MOVE ON` when pass)
