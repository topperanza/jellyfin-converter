# Milestone 5: Subtitle ranking policy consolidation
- Date: 2026-03-11
- Goal: reduce future drift by consolidating shared subtitle ranking policy so `select_internal_subtitles` and `build_subtitle_plan` use the same scoring path.
- Completion criteria: shared ranking helper/path is used for both internal selection and subtitle-plan construction, parity scenarios remain green, and no regression is observed in existing subtitle fixture coverage.

## Files changed
- `scripts/lib/media_filters.sh`
- `tests/suite_selection.sh`
- `tests/suite_ffmpeg.sh`
- `docs/codex/STATUS.md`
- `.codex/checkpoints/MILESTONE-5.md`

## Commands run
- `bash scripts/check-fast.sh`
- `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
- `bash scripts/check-changed.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Pass: `bash scripts/check-fast.sh`
- Pass: `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
- Pass: `bash scripts/check-changed.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- Pass: `bash scripts/check-full.sh`
- Added shared `subtitle_policy_rank` helper and wired both `select_internal_subtitles` and `build_subtitle_plan` to use it.
- Added mirrored parity tests for default-preference behavior inside English forced slot selection.

## Risks / next step
- Risk: future subtitle-ranking edits can still drift if changes bypass `subtitle_policy_rank`.
- Next step: define the next numbered milestone in `docs/codex/PLAN.md` and promote it in `docs/codex/STATUS.md`.
