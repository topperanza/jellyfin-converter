---
name: mtt-project-files-sync-audit
description: Use this skill to audit docs/project-files/ as a downstream ChatGPT Project export surface and determine sync readiness. Do not use it to gate implementation milestones by itself.
---

# mtt-project-files-sync-audit

## Trigger when
- You need to assess whether `docs/project-files/` is ready for ChatGPT Project upload sync.
- You need per-file classification: `current`, `stale`, `incomplete`, `missing`.
- You need an operator-facing recommendation: sync now vs update first.

## Do not trigger when
- You need milestone completion gating (`mtt-repo-milestone-review`).
- You need next milestone planning or commit/push execution.
- You need deep code correctness review outside export summaries.

## Procedure
1. Inspect all files under `docs/project-files/`.
2. Compare summaries against current canonical repo truth (code/tests/config and `docs/codex/*`).
3. Classify each file as `current`, `stale`, `incomplete`, or `missing`.
4. Decide export readiness:
   - `READY TO SYNC`
   - `NOT READY TO SYNC`
5. List minimal updates needed before next sync (if any).

## Guardrail
Always treat `docs/project-files/` as downstream export only; never elevate it above code/tests/config and `docs/codex/*` for milestone decisions.
