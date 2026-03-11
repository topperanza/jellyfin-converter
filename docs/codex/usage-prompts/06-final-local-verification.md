# 06 Final Local Verification

When to use: Use for final real-machine verification when work is local/bootstrap/toolchain-sensitive.
When to use: Also use as final confidence check before commit/push.
Run in: Codex Local app

```text
Task: run final local verification for milestone handoff readiness.

Execution order:
1) bash scripts/codex/setup.sh (fresh env) or bash scripts/codex/maintenance.sh (warm env)
2) run milestone-targeted validation
3) run bash scripts/check-fast.sh
4) run bash scripts/check-changed.sh HEAD~1 if present/relevant
5) run bash scripts/check-full.sh if justified

Checks:
- touched files remain milestone-scoped
- control-plane docs stay aligned (AGENTS/RUNBOOK/REPO_OVERVIEW/DOC_SYNC_MATRIX)
- docs/project-files remains downstream export only

Decision must be exactly one of:
- READY FOR COMMIT/PUSH
- ONE LAST PATCH NEEDED

Output required:
- commands run
- pass/fail/skip evidence
- decision
- if patch needed: narrow patch scope for next run
```
