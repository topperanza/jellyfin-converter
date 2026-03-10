# Milestone 3: Operator-facing runbook + resume reliability
- Date: 2026-03-10
- Goal: ensure long-running Codex tasks can be resumed and handed off cleanly.
- Completion criteria: runbook includes startup, checkpoint, and handoff instructions tied to actual repo scripts.

## Files changed
- `docs/codex/STATUS.md`
- `docs/project-files/codex-handoff.md`
- `docs/codex/PLAN.md`
- `.codex/checkpoints/MILESTONE-3.md`

## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`

## Results
- Pass at 2026-03-10 04:06 UTC: `bash scripts/check-fast.sh`
- Pass at 2026-03-10 04:06 UTC: `bash scripts/check-changed.sh HEAD~1`
- Validation evidence recorded in `docs/codex/STATUS.md`.
- Runbook/resume milestone closed with numbered-milestone continuity (`MILESTONE-4`) established in plan/status.

## Risks
- `select_internal_subtitles` and `build_subtitle_plan` still carry overlapping ranking logic; policy changes can drift without synchronized tests.

## Next-step owner prompt
- Execute `MILESTONE-4` from `docs/codex/PLAN.md` with focused parity coverage updates for internal selection vs ffmpeg subtitle plan ranking, then checkpoint and update status/project-files if workflow contracts change.
