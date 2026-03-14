# 04-blocker-patch.md

Implementation task for the current repository.

Goal:
Fix only the current blocking issues that prevent advancement.

This is a blocker-patch task, not a new milestone.

Hard rules:
- Do NOT expand scope beyond the listed blockers.
- Do NOT reopen unrelated repo areas.
- Do NOT do opportunistic cleanup.
- Keep diffs minimal and directly tied to the blockers.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` only for blocker-relevant documentation changes.
- Update canonical shared docs first if they exist; update adapters only when blocker resolution changes agent-facing behavior.

Inspect first:
- blocker list from the latest review
- `docs/agent-workflow/*` if present
- `docs/codex/DOC_SYNC_MATRIX.md`
- exact files implicated by the blockers
- relevant validation failures

Required procedure:
1. Restate blockers
2. Patch only those blockers
3. Run the narrowest meaningful validation
4. Update only blocker-relevant docs/adapters/exports
5. Return a concise blocker-fix summary

Output:
A) Blockers addressed
B) Files changed
C) Validation performed
D) Docs/adapters/exports updated
E) Remaining blocker risk
F) Status
G) Next suggested prompt

Next suggested prompt:
- `05-blocker-closure-check.md`