---
name: mtt-repo-milestone-review
description: Gate-focused milestone review against contract and blocking documentation rules.
---

# mtt-repo-milestone-review

## Objective
Assess one active milestone gate, not a full-repo redesign.

## Inputs
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- changed files relevant to the milestone

## Procedure
1. Identify active milestone contract and expected done state.
2. Verify implemented changes against that contract only.
3. Apply DOC_SYNC_MATRIX blocking vs non-blocking rules.
4. Return gate outcome: `BLOCKED` or `SAFE TO MOVE ON`.

## Output
- gate outcome
- blocking items
- non-blocking follow-ups
- minimal next actions
