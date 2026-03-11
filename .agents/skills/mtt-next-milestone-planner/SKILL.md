---
name: mtt-next-milestone-planner
description: Use this skill only after a milestone is explicitly SAFE TO MOVE ON, to select the correct next milestone from repo reality and produce one milestone-sized implementation plan plus a paste-ready execution prompt. Do not use for gate decisions.
---

# mtt-next-milestone-planner

## Trigger when
- Current milestone gate is PASS with explicit `SAFE TO MOVE ON`.
- You need to determine the next numbered milestone from actual repo state.
- You need one small, reviewable milestone plan with validation and doc-sync expectations.

## Do not trigger when
- Current milestone has unresolved blocking issues.
- You need to assess milestone completion/gate status (`mtt-repo-milestone-review`).
- You only need docs/project-files export audit or commit/push tracking.

## Procedure
1. Confirm prior milestone gate result is PASS and marked `SAFE TO MOVE ON`.
2. Read `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, and current diffs to infer next valid milestone target.
3. Produce exactly one coherent milestone proposal:
   - objective
   - scope/files
   - validation commands (fast first, then targeted/full as needed)
   - required docs updates from `docs/codex/DOC_SYNC_MATRIX.md`
   - risks/rollback notes
4. Produce a paste-ready Codex prompt for executing that single milestone.

## Output constraints
- One milestone only (no multi-milestone roadmap dump).
- Explicitly identify required vs non-blocking documentation updates.
- Keep naming aligned with existing milestone scheme (`MILESTONE-<n>`).
