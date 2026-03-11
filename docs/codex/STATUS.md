# Codex Run Status

_Last updated: 2026-03-11 00:46 UTC_

## Current task
- Added repo-native Codex skills under `.agents/skills/` for milestone review, next-milestone planning, project-files sync audit, and commit/push tracking.
- Added `docs/codex/automations/` prompt templates for Codex app setup (weekly milestone drift audit, weekly project-files sync audit, pre-release truth audit).
- Updated control-plane docs integration in `README.md` and `docs/codex/RUNBOOK.md` for automation/skill discoverability and required sequence wording.


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
- `.agents/skills/mtt-repo-milestone-review/SKILL.md`
- `.agents/skills/mtt-repo-milestone-review/agents/openai.yaml`
- `.agents/skills/mtt-next-milestone-planner/SKILL.md`
- `.agents/skills/mtt-next-milestone-planner/agents/openai.yaml`
- `.agents/skills/mtt-project-files-sync-audit/SKILL.md`
- `.agents/skills/mtt-project-files-sync-audit/agents/openai.yaml`
- `.agents/skills/mtt-commit-push-tracker/SKILL.md`
- `.agents/skills/mtt-commit-push-tracker/agents/openai.yaml`
- `docs/codex/automations/README.md`
- `docs/codex/automations/weekly-milestone-drift-audit.md`
- `docs/codex/automations/weekly-project-files-sync-audit.md`
- `docs/codex/automations/pre-release-truth-audit.md`
- `README.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/STATUS.md`


## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`


## Results
- Added four focused instruction-only repo skills with explicit trigger/non-trigger rules and explicit invocation policy (`allow_implicit_invocation: false`).
- Added Codex app automation setup docs and paste-ready prompt templates without introducing unsupported scheduled-file formats.
- RUNBOOK sequence now explicitly states: implement -> validate -> update required docs via DOC_SYNC_MATRIX.md -> milestone gate -> checkpoint -> commit/push.

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
