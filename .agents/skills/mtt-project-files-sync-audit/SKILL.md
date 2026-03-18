---
name: mtt-project-files-sync-audit
description: Audit docs/project-files as a downstream export sync surface.
---

# mtt-project-files-sync-audit

## Objective
Check freshness of `docs/project-files/*` without treating it as source-of-truth.

## Rules
- `docs/project-files/*` is downstream export only.
- Drift is non-blocking unless explicitly promoted by milestone contract.

## Procedure
1. Compare `docs/project-files/*` with current code/tests/config and `docs/codex/*`.
2. Identify stale or missing export summaries.
3. Recommend concise sync updates.
4. Classify findings as non-blocking follow-ups by default.

## Output
- stale export list
- recommended updates
- blocking classification rationale
