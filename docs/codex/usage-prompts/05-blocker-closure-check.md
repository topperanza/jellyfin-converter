# 05-blocker-closure-check.md

Review-only task.

Goal:
Determine whether the currently listed blockers have been fixed and whether the repository can now advance.

This is a blocker-closure check, not a fresh milestone gate and not a full repo audit.

Hard rules:
- Do NOT implement changes.
- Do NOT revisit unrelated milestone history.
- Check only the named blockers plus protected regression areas.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` to distinguish blocking vs non-blocking documentation items.
- `docs/project-files/*` should only be checked if the blocker list or `DOC_SYNC_MATRIX.md` makes it relevant.

Inspect first:
- prior blocker list
- `docs/agent-workflow/*` if present
- `docs/codex/DOC_SYNC_MATRIX.md`
- exact files changed to fix blockers
- relevant tests/check results
- required docs/adapters/exports tied to those blockers

Required procedure:
1. Build a blocker-closure matrix
2. Verify each named blocker
3. Check protected regression areas only
4. Decide whether the repo can advance

Output:
A) Blocker closure matrix
B) Regression check
C) Decision
D) Remaining blockers only
E) If passed: confirm repo is ready for next step
F) Next suggested prompt

Decision values:
- `SAFE TO MOVE ON`
- `STILL BLOCKED`

Next suggested prompt rules:
- If `SAFE TO MOVE ON` and local verification is needed:
  `06A-local-handoff+verification.md` or `06B-local-verification`
- If `SAFE TO MOVE ON` and no local verification is needed:
  `07A-commit-push.md`
- If `STILL BLOCKED`:
  `04-blocker-patch.md`