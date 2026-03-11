# 02 Milestone Implementation

When to use: Use to implement exactly one active milestone-sized change from PLAN.
Run in: Codex Cloud

```text
Task: implement exactly one active milestone contract.

Execution order:
1) inspect AGENTS/PLAN/STATUS/RUNBOOK/REPO_OVERVIEW/DOC_SYNC_MATRIX
2) implement milestone-scoped changes only
3) run narrow milestone-specific validation first
4) run bash scripts/check-fast.sh
5) run bash scripts/check-changed.sh only if present and relevant
6) run bash scripts/check-full.sh only if justified by scope/risk
7) update required docs per DOC_SYNC_MATRIX
8) record command evidence, results, follow-ups in docs/codex/STATUS.md
9) update checkpoint .codex/checkpoints/MILESTONE-<id>.md

Rules:
- Source-of-truth order applies; docs/project-files is downstream only.
- No unrelated refactors or formatting churn.
- Do not broaden into full-repo audit during milestone implementation.

Output required:
- files changed
- commands run
- results (pass/fail/skip)
- blockers and non-blocking follow-ups
- ready for milestone gate
```
