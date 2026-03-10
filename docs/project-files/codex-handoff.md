# Codex Handoff

## How Codex should work safely here
- Follow `AGENTS.md` and `docs/codex/RUNBOOK.md` before editing.
- Keep changes milestone-scoped, reviewable, and deterministic.
- Prefer repo-native scripts over ad-hoc commands.
- Do not modify unrelated scaffolding.

## Milestone sizing and pattern
Default sequence:
1. Inspect
2. Confirm/update `docs/codex/PLAN.md`
3. Implement one coherent milestone
4. Validate with repo scripts
5. Update `docs/codex/STATUS.md`
6. Update affected `docs/project-files/*`
7. Checkpoint (`.codex/checkpoints/MILESTONE-<n>.md`)

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
