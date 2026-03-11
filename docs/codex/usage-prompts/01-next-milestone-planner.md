# 01 Next Milestone Planner

When to use: Use after the current milestone has passed and you need the next numbered milestone.
When to use: Planning only; do not implement code/doc changes in this run.
Run in: Codex Cloud

```text
Task: plan the next numbered milestone only.

Read first:
- AGENTS.md
- docs/codex/PLAN.md
- docs/codex/STATUS.md
- docs/codex/RUNBOOK.md
- docs/codex/REPO_OVERVIEW.md
- docs/codex/DOC_SYNC_MATRIX.md
- latest .codex/checkpoints/MILESTONE-<n>.md

Rules:
- Keep source-of-truth order: code/tests/config first, docs/codex next, docs/project-files last (downstream only).
- Use one coherent milestone with numbered ID in plan order (MILESTONE-<n>).
- Keep scope small, reviewable, and rollback-safe.
- Milestone completion rule: PLAN contract + DOC_SYNC_MATRIX blocking rules.
- Non-blocking doc hygiene must be recorded as follow-up, not as blocker.

Output required:
1) milestone ID, title, objective
2) scope and exact files likely to change
3) implementation plan (stepwise)
4) validation plan in canonical order
5) risks and rollback notes
6) paste-ready implementation prompt for Prompt 02
```
