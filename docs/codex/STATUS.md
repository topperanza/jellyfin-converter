# Codex Run Status

_Last updated: 2026-03-10 10:05 UTC_

## Current task
- Refined Codex control-plane documentation to provide one stable repo-overview + doc-sync interpretation layer for future milestones.
- Expanded `docs/codex/REPO_OVERVIEW.md` with runtime model, subsystem map, milestone rules, invariants, validation order, and operator workflow.
- Reworked `docs/codex/DOC_SYNC_MATRIX.md` into a deterministic change-type matrix with explicit blocking vs non-blocking rules.
- Updated runbook/handoff references so operators treat overview + matrix as canonical interpretation and follow the same execution sequence.

## Current milestone
- ID: MILESTONE-5
- Title: Subtitle ranking policy consolidation
- Goal: reduce future drift by consolidating shared subtitle ranking policy so `select_internal_subtitles` and `build_subtitle_plan` use the same scoring path.
- Completion criteria: shared ranking helper/path is used for both internal selection and subtitle-plan construction, parity scenarios remain green, and no regression is observed in existing subtitle fixture coverage.

## Last completed milestone
- ID: MILESTONE-4
- Goal: reduce policy drift risk between `select_internal_subtitles` and `build_subtitle_plan` with focused parity assertions.
- Checkpoint: `.codex/checkpoints/MILESTONE-4.md`

## Additional completed closure (outside numbered plan milestones)
- ID: MILESTONE-docs-project-files
- Goal: keep canonical low-churn project summaries and milestone sync guidance aligned.
- Checkpoint: `.codex/checkpoints/MILESTONE-docs-project-files.md`

## Files touched
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/STATUS.md`
- `docs/project-files/codex-handoff.md`

## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Established a stable control-plane interpretation layer in `docs/codex/REPO_OVERVIEW.md` + `docs/codex/DOC_SYNC_MATRIX.md` with explicit gate logic.
- Preserved milestone execution sequence in runbook as: implement -> validate -> sync required docs -> milestone gate -> checkpoint -> commit/push.
- Synced project handoff guidance to point to overview/matrix as canonical for future Codex resume flows.
- Validation command results:
  - Pass: `bash scripts/check-fast.sh`
  - Pass: `bash scripts/check-changed.sh HEAD~1`
  - Pass: `bash scripts/check-full.sh`

## Blockers
- none

## Known risks
- `select_internal_subtitles` and `build_subtitle_plan` remain separate ranking call sites until `MILESTONE-5` implementation lands.

## Next step
- Implement `MILESTONE-5` with narrow changes in `scripts/lib/media_filters.sh` and mirrored test updates in `tests/suite_selection.sh` and `tests/suite_ffmpeg.sh`, then checkpoint `.codex/checkpoints/MILESTONE-5.md`.
