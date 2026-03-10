# Codex Run Status

_Last updated: 2026-03-10 10:35 UTC_

## Current task
- Completed MILESTONE-2 by mapping existing subtitle discovery/selection coverage and adding only missing edge-case tests.
- Promoted active milestone tracking to MILESTONE-3.

## Current milestone
- ID: MILESTONE-3
- Title: Operator-facing runbook + resume reliability
- Goal: ensure long-running Codex tasks can be resumed and handed off cleanly.
- Completion criteria: runbook includes startup, checkpoint, and handoff instructions tied to actual repo scripts.

## Last completed milestone
- ID: MILESTONE-2
- Goal: add focused tests around highest-risk media-selection edges before feature work.
- Checkpoint: `.codex/checkpoints/MILESTONE-2.md`

## Additional completed closure (outside numbered plan milestones)
- ID: MILESTONE-docs-project-files
- Goal: keep canonical low-churn project summaries and milestone sync guidance aligned.
- Checkpoint: `.codex/checkpoints/MILESTONE-docs-project-files.md`

## Files touched
- `tests/suite_discovery.sh`
- `tests/suite_selection.sh`
- `tests/fixtures/discovery/strict_anchoring/Movie.forced.srt`
- `tests/fixtures/discovery/strict_anchoring/MovieX.eng.srt`
- `tests/fixtures/eng_default_vs_nondefault.txt`
- `tests/fixtures/eng_text_vs_bitmap.txt`
- `tests/fixtures/fallback_non_wanted.txt`
- `.codex/checkpoints/MILESTONE-2.md`
- `docs/codex/STATUS.md`

## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Added strict discovery anchoring coverage for `und+forced` sidecars and prefix-collision rejection.
- Added selection coverage for: default-vs-nondefault normal slot, text-vs-bitmap tie in same slot, and fallback when no wanted/forced subtitles exist.
- Validation passed: fast, changed-file, and full checks.

## Blockers
- none

## Known risks
- `select_internal_subtitles` and `build_subtitle_plan` have overlapping ranking behavior but separate implementations; future policy changes require synchronized tests in both areas.

## Next step
- Execute MILESTONE-3 with runbook/resume audit only, keeping scope doc-focused and checkpointed.
