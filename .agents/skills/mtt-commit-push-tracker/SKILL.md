---
name: mtt-commit-push-tracker
description: Use this skill after implementation is complete to verify changed scope, run the lightest sufficient checks, ensure DOC_SYNC_MATRIX tracking surfaces are covered, and produce coherent milestone-aware commit/push steps. Do not use for milestone gating decisions.
---

# mtt-commit-push-tracker

## Trigger when
- You are preparing to finalize a milestone with commit/push.
- You need verification of changed files, docs/test updates, and required tracking surfaces.
- You need safe push guidance (no force push).

## Do not trigger when
- Implementation is still in progress.
- You need a milestone gate verdict (`mtt-repo-milestone-review`).
- You only need project-files export readiness or next milestone planning.

## Procedure
1. Inspect `git status`, staged/unstaged diff summary, and changed tests/docs.
2. Check required tracking surfaces based on `docs/codex/DOC_SYNC_MATRIX.md`.
3. Run lightest sufficient validation for the changed scope (fast first, then changed/full only when needed).
4. Prepare coherent milestone-aware commit message(s) scoped to completed work.
5. Push safely to remote without force.
6. Report commit hash(es), pushed branch, and validations run.

## Output format
- Change scope summary
- Required tracking surfaces status
- Validation commands + outcomes
- Commit and push record
