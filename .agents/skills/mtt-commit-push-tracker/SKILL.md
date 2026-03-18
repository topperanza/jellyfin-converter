---
name: mtt-commit-push-tracker
description: Verify commit/push tracking surfaces after gate has passed.
---

# mtt-commit-push-tracker

## Objective
Confirm required tracking surfaces are updated before/with commit push activity.

## Preconditions
- Milestone gate is already `SAFE TO MOVE ON`.

## Procedure
1. Read `docs/codex/DOC_SYNC_MATRIX.md` and `docs/codex/STATUS.md`.
2. Verify blocking tracking surfaces are current for the completed milestone.
3. Confirm non-blocking items are listed as follow-ups.
4. Report commit/push readiness and missing updates.

## Output
- tracking readiness status
- missing blocking updates
- non-blocking follow-up gaps
- recommended commit/push next step
