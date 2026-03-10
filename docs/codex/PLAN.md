# Codex Long-Run Plan (Phase: workflow hardening + subtitle pipeline readiness)

_Last refreshed: 2026-03-10_

## Milestone sequence

Milestone closure rule: before checkpointing, update any affected `docs/project-files/*` summaries when scope, architecture, workflow behavior, safety boundaries, validation expectations, or operator-facing process changes.

### Milestone 0 (ID: MILESTONE-0) — Repo review + plan confirmation
- **Objective:** Confirm current health, validation entrypoints, and codex scaffolding baseline.
- **Scope / files:** `AGENTS.md`, `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, `.codex/checkpoints/MILESTONE-0.md`.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-full.sh`
- **Completion criteria:** baseline checks green; review findings and next-phase milestones recorded.
- **Risks / rollback:** documentation-only; rollback by reverting docs if plan needs re-scope.
- **Checkpoint update:** write findings and command results to `.codex/checkpoints/MILESTONE-0.md` and `docs/codex/STATUS.md`.

### Milestone 1 (ID: MILESTONE-1) — Validation workflow hardening
- **Objective:** Tighten validation ergonomics for incremental runs without changing conversion behavior.
- **Scope / files:** `scripts/check-changed.sh`, `scripts/check-fast.sh`, `scripts/check-full.sh`, `docs/codex/RUNBOOK.md` (if command semantics change).
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
  - `bash scripts/check-full.sh`
- **Completion criteria:** changed-file validation has clear base-ref behavior and remains Bash 3.2-safe.
- **Risks / rollback:** accidental over-triggering of checks; rollback by restoring previous check script logic.
- **Checkpoint update:** record changed-file behavior and expected invocation patterns in status/checkpoint.

### Milestone 2 (ID: MILESTONE-2) — Subtitle/discovery safety coverage expansion
- **Objective:** Add focused tests around highest-risk media-selection edges before feature work.
- **Scope / files:** `tests/suite_discovery.sh`, `tests/suite_selection.sh`, optional fixtures under `tests/fixtures/`.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `./tests/run.sh tests/suite_discovery.sh tests/suite_selection.sh`
  - `bash scripts/check-full.sh`
- **Completion criteria:** new tests cover identified edge cases and pass consistently on Bash 3.2-compatible shell.
- **Risks / rollback:** flaky fixture assumptions; rollback by removing unstable fixture paths.
- **Checkpoint update:** log new scenarios and any unresolved edge-case risks.

### Milestone 3 (ID: MILESTONE-3) — Operator-facing runbook + resume reliability
- **Objective:** Ensure long-running Codex tasks can be resumed and handed off cleanly.
- **Scope / files:** `docs/codex/RUNBOOK.md`, `docs/codex/STATUS.md`, `.codex/checkpoints/*.md`, optionally `AGENTS.md` for clarified routing.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
- **Completion criteria:** runbook includes startup, checkpoint, and handoff instructions tied to actual repo scripts.
- **Risks / rollback:** documentation drift; rollback by reverting runbook-only changes.
- **Checkpoint update:** finalize status with current milestone, command evidence, and next action owner prompt.

### Milestone 4 (ID: MILESTONE-4) — Subtitle ranking parity hardening
- **Objective:** Reduce ranking-policy drift risk between `select_internal_subtitles` and `build_subtitle_plan` with focused parity assertions.
- **Scope / files:** `tests/suite_selection.sh`, `tests/suite_ffmpeg.sh`, optional fixtures under `tests/fixtures/`.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `./tests/run.sh tests/suite_selection.sh`
  - `./tests/run.sh tests/suite_ffmpeg.sh`
  - `bash scripts/check-changed.sh HEAD~1`
- **Completion criteria:** added/updated tests assert aligned ranking outcomes across internal selection and ffmpeg subtitle plan behavior for shared policy scenarios.
- **Risks / rollback:** fixture overfitting can hide real drift; rollback by removing brittle assertions and retaining only deterministic parity cases.
- **Checkpoint update:** record parity scenarios, command results, unresolved policy ambiguities, and explicit next-step handoff prompt.

### Milestone 5 (ID: MILESTONE-5) — Subtitle ranking policy consolidation
- **Objective:** Reduce future drift by consolidating shared subtitle ranking policy so `select_internal_subtitles` and `build_subtitle_plan` use the same scoring path.
- **Scope / files:** `scripts/lib/media_filters.sh`, `tests/suite_selection.sh`, `tests/suite_ffmpeg.sh`, optional fixtures under `tests/fixtures/`, and affected `docs/project-files/*` summaries if workflow/validation expectations change.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
  - `bash scripts/check-changed.sh HEAD~1`
  - `bash scripts/check-full.sh`
- **Completion criteria:** shared ranking helper/path is used for both internal selection and subtitle-plan construction, parity scenarios remain green, and no regression is observed in existing subtitle fixture coverage.
- **Risks / rollback:** ranking-policy merge can introduce subtle ordering regressions; rollback by reverting consolidation changes and retaining parity tests that expose divergence.
- **Checkpoint update:** record consolidation scope, touched ranking call sites, command evidence, unresolved policy questions, and explicit next-step owner prompt.

## Preferred validation after each milestone
```bash
bash scripts/check-fast.sh
bash scripts/check-changed.sh HEAD~1
```

## Final handoff validation
```bash
bash scripts/check-fast.sh
bash scripts/check-full.sh
```
