# Codex Run Status

_Last updated: 2026-03-10 04:35 UTC_

## Current task
- Closed MILESTONE-4 by hardening subtitle-ranking parity coverage and fixing milestone validation command semantics.
- Captured milestone validation evidence and updated project-files validation wording to match actual runner behavior.

## Current milestone
- ID: none (awaiting next numbered milestone in `docs/codex/PLAN.md`)
- Title: plan refresh pending
- Goal: define the next numbered implementation milestone after MILESTONE-4 closure.
- Completion criteria: `docs/codex/PLAN.md` and `docs/codex/STATUS.md` agree on the next active milestone.

## Last completed milestone
- ID: MILESTONE-4
- Goal: reduce policy drift risk between `select_internal_subtitles` and `build_subtitle_plan` with focused parity assertions.
- Checkpoint: `.codex/checkpoints/MILESTONE-4.md`

## Additional completed closure (outside numbered plan milestones)
- ID: MILESTONE-docs-project-files
- Goal: keep canonical low-churn project summaries and milestone sync guidance aligned.
- Checkpoint: `.codex/checkpoints/MILESTONE-docs-project-files.md`

## Files touched
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
- MILESTONE-4 parity coverage now includes mirrored scenarios in selection and ffmpeg suites:
  - default track preference (`eng_default_vs_nondefault`)
  - text-over-bitmap preference (`eng_text_vs_bitmap`)
  - forced+normal slot retention (`eng_forced_and_normal`)
- `tests/run.sh` now accepts multiple explicit patterns, removing command ambiguity for scoped validations.
- Validation passed at 2026-03-10 04:35 UTC for all milestone commands plus full validation:
  - `bash scripts/check-fast.sh`
  - `./tests/run.sh tests/suite_selection.sh`
  - `./tests/run.sh tests/suite_ffmpeg.sh`
  - `bash scripts/check-changed.sh HEAD~1`
  - `bash scripts/check-full.sh`

## Blockers
- none

## Known risks
- `select_internal_subtitles` and `build_subtitle_plan` still use separate ranking code paths; future policy changes still require synchronized parity-test updates.

## Next step
- Define and scope the next numbered milestone in `docs/codex/PLAN.md`, then promote it in `docs/codex/STATUS.md` before implementation.
