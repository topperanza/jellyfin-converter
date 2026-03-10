# Milestone 4: Subtitle ranking parity hardening
- Date: 2026-03-10
- Goal: reduce ranking-policy drift risk between `select_internal_subtitles` and `build_subtitle_plan` with focused parity assertions.
- Completion criteria: added/updated tests assert aligned ranking outcomes across internal selection and ffmpeg subtitle plan behavior for shared policy scenarios.

## Files changed
- `tests/run.sh`
- `tests/suite_selection.sh`
- `tests/suite_ffmpeg.sh`
- `tests/fixtures/eng_forced_and_normal.txt`
- `docs/codex/PLAN.md`
- `docs/codex/RUNBOOK.md`
- `docs/project-files/validation-summary.md`
- `.codex/checkpoints/MILESTONE-4.md`
- `docs/codex/STATUS.md`

## Commands run
- `bash scripts/check-fast.sh`
- `./tests/run.sh tests/suite_selection.sh`
- `./tests/run.sh tests/suite_ffmpeg.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Pass: `bash scripts/check-fast.sh`
- Pass: `./tests/run.sh tests/suite_selection.sh`
- Pass: `./tests/run.sh tests/suite_ffmpeg.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- Pass: `bash scripts/check-full.sh`
- Milestone command semantics are now unambiguous for scoped suite runs.
- Parity coverage now includes mirrored assertions for default preference, codec preference, and forced+normal slot retention.

## Risks / next step
- Risk: ranking policy still lives in separate functions and requires synchronized test maintenance on future policy changes.
- Next step: define the next numbered milestone in `docs/codex/PLAN.md` and promote it in `docs/codex/STATUS.md` before implementation.
