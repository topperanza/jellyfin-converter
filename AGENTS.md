# AGENTS.md

## Purpose
This repository is Codex-ready and should be worked in using small, reviewable, milestone-based changes.

## Core working rules
- Keep diffs narrow and task-scoped.
- Do not perform unrelated refactors or formatting churn.
- Preserve existing repo-native tooling and conventions unless the task explicitly changes them.
- Do not introduce case-only path duplicates; generic repo directories should use lowercase names.
- Never add or expose secrets in tracked files, logs, fixtures, or examples.
- Prefer deterministic, reproducible behavior over convenience shortcuts.
- Ask questions only if blocked; otherwise make one short assumption and proceed.
- Selected files under `docs/project-files/` are intended to be uploaded to this repository's own ChatGPT Project to keep future chats aligned with current repo reality. Keep these files concise, factual, and low-churn.
- Do not duplicate the full repo documentation in `docs/project-files/`. Prefer concise summaries, invariants, handoff notes, and decision logs.
- When a milestone changes product scope, architecture, workflow behavior, safety boundaries, validation expectations, or operator-facing process, update the relevant file(s) under `docs/project-files/` before checkpointing.
- Milestone completion is determined by the milestone contract plus the blocking rules in docs/codex/DOC_SYNC_MATRIX.md. Non-blocking documentation hygiene items should be recorded as follow-ups and must not automatically block advancement.
- docs/project-files/ exists to generate concise files for upload into this repository’s ChatGPT Project. It is a downstream sync surface, not the primary source of truth for Codex. Code, tests, config, and docs/codex/* govern milestone decisions.

## Validation order
Run validation in this order unless the task explicitly requires otherwise:
1. narrow milestone-specific validation first
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` (only if present and useful)
4. `bash scripts/check-full.sh` (only if justified)

## Codex environment
- setup: `bash scripts/codex/setup.sh`
- maintenance: `bash scripts/codex/maintenance.sh`

## Milestone workflow
1. Inspect current repo state
2. Update or confirm plan in `docs/codex/PLAN.md`
3. Execute one coherent milestone only
4. Run milestone validation
5. Update required docs per `docs/codex/DOC_SYNC_MATRIX.md`
6. Apply milestone gate and record pass/follow-ups in `docs/codex/STATUS.md`
7. Checkpoint clearly before stopping

## Repo-specific invariants
- Source of truth:
  - The repo's media conversion rules, output expectations, and tests define intended behavior.
- Primary workflow:
  - Deterministic media conversion pipeline for Jellyfin-compatible outputs.
- Validation specifics:
  - Prefer fast output validation first, then broader conversion/test paths.
  - Verify codec, container, duration, and stream mapping explicitly for changed paths.
- High-risk paths:
  - ffmpeg command generation
  - codec/container selection
  - stream mapping
  - metadata / subtitle handling
  - output verification
- Safety constraints:
  - Originals untouched.
  - Media transforms must be deterministic and reproducible.
  - Prefer explicit codec/container rules over implicit ffmpeg behavior.
