# 04 Blocker Patch

When to use: Use only when Prompt 03 decision is FIX BLOCKERS FIRST.
Run in: Codex Cloud

```text
Task: patch only the listed blockers from the latest gate report.

Rules:
- Fix blockers only; no broad milestone reopening.
- Keep diff minimal and directly tied to blocker list.
- Re-run narrow blocker-targeted validation first.
- Re-run bash scripts/check-fast.sh.
- Update STATUS/checkpoint only for blocker-related evidence.
- Do not run full repo audit here.

Output required:
- blockers addressed
- files changed
- commands run
- results
- handoff to Prompt 05
```
