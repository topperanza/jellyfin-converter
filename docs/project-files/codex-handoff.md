# Codex Handoff

## How Codex should work safely here
- Follow `AGENTS.md` and `docs/codex/RUNBOOK.md` before editing.
- Treat `docs/codex/REPO_OVERVIEW.md` + `docs/codex/DOC_SYNC_MATRIX.md` as the canonical interpretation layer for milestone gating and doc-sync decisions.
- Keep changes milestone-scoped, reviewable, and deterministic.
- Prefer repo-native scripts over ad-hoc commands.
- Do not modify unrelated scaffolding.

## Milestone sizing and pattern
Default sequence:
1. Inspect
2. Confirm/update `docs/codex/PLAN.md`
3. Implement one coherent milestone
4. Validate with repo scripts
5. Sync required docs per `docs/codex/DOC_SYNC_MATRIX.md` (project-files updates only when matrix says material)
6. Apply milestone gate and record pass/follow-ups in `docs/codex/STATUS.md`
7. If blocked, fix blockers only and run a targeted blocker-closure check
8. Checkpoint (`.codex/checkpoints/MILESTONE-<n>.md`)
9. Commit/push after gate is safe to move on

## Milestone ID and resume policy
- Active implementation work must use numbered milestones from `docs/codex/PLAN.md` (`MILESTONE-<n>` in plan order).
- Non-numbered milestone IDs are exceptional documentation-only closures and must be tracked under `docs/codex/STATUS.md` additional closures, not as active milestones.
- Resume/handoff is complete only when `docs/codex/STATUS.md` and `.codex/checkpoints/MILESTONE-<n>.md` both record the latest validation evidence and next-step ownership.

## Files to check first
- `AGENTS.md`
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/project-files/*.md` (for summary alignment)

## Preferred change pattern
- Small patches with exact file/command evidence.
- Fast validation first; full validation when milestone risk/scope requires it.
- Update docs only where behavior/contracts changed.

## High-risk areas (avoid touching without need)
- ffmpeg command generation paths
- codec/container policy and stream mapping
- subtitle/audio selection rules
- deletion and sidecar safety behavior
