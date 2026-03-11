# Codex Run Status

_Last updated: 2026-03-11 11:05 UTC_

## Current task
- Implemented MILESTONE-5 subtitle ranking-policy consolidation so both `select_internal_subtitles` and `build_subtitle_plan` use a shared ranking helper.
- Added mirrored parity assertions in selection/ffmpeg suites for default preference within the forced English slot.
- Collected milestone command evidence and checkpointed MILESTONE-5 completion.

## Current milestone
- ID: MILESTONE-5
- Title: Subtitle ranking policy consolidation
- Goal: reduce future drift by consolidating shared subtitle ranking policy so `select_internal_subtitles` and `build_subtitle_plan` use the same scoring path.
- Completion criteria: shared ranking helper/path is used for both internal selection and subtitle-plan construction, parity scenarios remain green, and no regression is observed in existing subtitle fixture coverage.

## Last completed milestone
- ID: MILESTONE-5
- Goal: reduce future drift by consolidating shared subtitle ranking policy so `select_internal_subtitles` and `build_subtitle_plan` use the same scoring path.
- Checkpoint: `.codex/checkpoints/MILESTONE-5.md`

## Additional completed closure (outside numbered plan milestones)
- ID: MILESTONE-docs-project-files
- Goal: keep canonical low-churn project summaries and milestone sync guidance aligned.
- Checkpoint: `.codex/checkpoints/MILESTONE-docs-project-files.md`

## Files touched
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
- `subtitle_policy_rank` now defines shared language/forced/default/commentary/codec ranking policy and is used by both subtitle-selection call paths.
- Added mirrored tests `test_selection_prefers_default_within_forced_slot` and `test_plan_prefers_default_within_forced_slot` to enforce parity on forced-slot default preference.
- MILESTONE-5 contract is satisfied and checkpointed.
- Validation command results:
  - Pass: `bash scripts/check-fast.sh`
  - Pass: `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
  - Pass: `bash scripts/check-changed.sh`
  - Pass: `bash scripts/check-changed.sh HEAD~1`
  - Pass: `bash scripts/check-full.sh`

## Blockers
- none

## Known risks
- Shared helper misuse risk remains if future subtitle policy edits bypass `subtitle_policy_rank`; parity tests should be kept mirrored.

## Next step
- Define and activate the next numbered milestone in `docs/codex/PLAN.md` before implementation.
