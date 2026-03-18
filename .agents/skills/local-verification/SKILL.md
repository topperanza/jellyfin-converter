---
name: local-verification
description: Final local verification pass for already-integrated work before commit
---

> Canonical source: docs/codex/usage-prompts/06B-local-verification.md

Precondition: run in a local environment with git, remote access, and the working repo checked out.

# 06B-local-verification.md

Final local verification task for the current repository.

Run this with a local-capable agent only.

Goal:
Perform a final local verification pass to confirm that the completed work is operationally sound on the real local environment and remains aligned with the repo control plane.

This is a verification task, not a new implementation task.

Hard rules:
- Do NOT do broad new implementation work.
- Do NOT reopen milestone history unless there is direct regression evidence.
- Prefer verification and only the smallest corrective patch if a last-mile issue is found.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` for required tracking surfaces.
- Treat `docs/project-files/*` as downstream export only unless explicitly required.

Inspect first:
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- `AGENTS.md` if present
- `CLAUDE.md` if present
- `scripts/codex/setup.sh` if present
- `scripts/codex/maintenance.sh` if present
- `scripts/check-fast.sh`
- `scripts/check-changed.sh` if present
- `scripts/check-full.sh` if present
- relevant build/runtime/config files
- relevant test directories

Required procedure:
1. Verify control-plane coherence
2. Verify adapter coherence if adapters were touched
3. Verify repo-specific environment/bootstrap scripts if relevant
4. Verify repo-specific validation scripts if relevant
5. Run final local validation:
   - narrow milestone-specific checks first
   - `bash scripts/check-fast.sh`
   - `bash scripts/check-changed.sh` if present and relevant
   - `bash scripts/check-full.sh` only if justified
6. Decide:
   - `READY FOR COMMIT/PUSH`
   - `ONE LAST PATCH NEEDED`

Output:
A) Verification verdict
B) Verification matrix
C) Validation performed
D) Remaining blocker if any
E) Final recommendation
F) Short summary
G) Next suggested prompt

Next suggested prompt rules:
- If `READY FOR COMMIT/PUSH`:
  `07A-commit-push.md`
- If `ONE LAST PATCH NEEDED`:
  `04-blocker-patch.md`
