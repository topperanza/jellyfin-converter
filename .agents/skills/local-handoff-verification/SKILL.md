---
name: local-handoff-verification
description: Bring completed cloud work into the local repo and run a final local verification pass before commit
---

> Canonical source: docs/codex/usage-prompts/06A-local-handoff+verification.md

Precondition: run in a local environment with git, remote access, and the working repo checked out.

# 06A-local-handoff+verification.md

Final local handoff + verification task for the current repository.

Run this with a local-capable agent only.

Goal:
Safely bring the completed remote/cloud agent work into the real local repository, then perform a final local verification pass to confirm the work is operationally sound on the real local environment and remains aligned with the repo control plane.

This is a verification task, not a new implementation task.

Hard rules:
- Do NOT commit.
- Do NOT push.
- Do NOT open, merge, or finalize a PR.
- Do NOT do broad new implementation work.
- Do NOT reopen milestone history unless there is direct regression evidence.
- Prefer verification and only the smallest corrective patch if a real last-mile issue is found.
- Preserve any existing local uncommitted work.
- If the current local checkout is not safe to use, protect local work first or stop with a precise blocker.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` for required tracking surfaces.
- Treat `docs/project-files/*` as downstream export only unless explicitly required by the canonical workflow docs.
- Treat `AGENTS.md` and `CLAUDE.md` as adapters, not the primary source of truth.
- Treat this as a final verification pass, not a broad repo audit.

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

1. Verify local Git safety before handoff
   - Run:
     - `git status --short`
     - `git branch --show-current`
   - Determine whether the current local checkout is safe for handoff.
   - If unrelated local uncommitted changes already exist:
     - do NOT overwrite them
     - protect them first using the safest minimal approach
     - prefer stash or a separate worktree if needed
     - if safe handoff cannot proceed without risk, stop and report the exact blocker
   - Record exactly how local state was protected, or state that no protection was needed.

2. Bring the completed remote/cloud work into the local repository
   - Prefer the supported handoff path for the agent/tool used.
   - If a remote branch exists, fetch it and switch to the correct local branch or integrate it into the intended working branch without committing.
   - If only a patch/diff exists, apply it locally using the safest reviewable method.
   - If neither a branch nor a patch/diff is available, stop and report `BLOCKED`.
   - Do NOT commit or push during this process.
   - After handoff, confirm with:
     - `git status --short`
     - `git branch --show-current`
     - `git diff --stat`
   - State the exact retrieval method used.

3. Verify control-plane coherence
   - Confirm current work still aligns with:
     - canonical shared workflow docs if present
     - `PLAN.md`
     - `STATUS.md`
     - `RUNBOOK.md`
     - `REPO_OVERVIEW.md`
     - `DOC_SYNC_MATRIX.md`
   - Check adapter coherence only if `AGENTS.md` or `CLAUDE.md` were touched.
   - Record only milestone-relevant drift; do NOT expand into a full repo audit.

4. Verify repo-specific environment/bootstrap scripts if relevant
   - Check whether setup/maintenance/bootstrap paths still behave as expected for the completed milestone scope.
   - Only inspect or run what is relevant to this milestone and the real local environment.
   - If not relevant, say so explicitly.

5. Verify repo-specific validation scripts if relevant
   - Confirm validation scripts still reflect repo reality for the current milestone scope.
   - Note script drift only if it affects current verification or handoff safety.

6. Run final local validation
   - Run narrow milestone-specific checks first.
   - Then run:
     - `bash scripts/check-fast.sh`
   - Then run:
     - `bash scripts/check-changed.sh`
     if present and relevant.
   - Then run:
     - `bash scripts/check-full.sh`
     only if justified by scope, failures, or explicit repo policy.
   - Record exactly what was run and the result of each step.
   - If a heavier check is skipped, say exactly why it was not justified.

7. Review for last-mile issues
   - If verification is clean, do not make extra edits.
   - If a real last-mile issue is found, apply only the smallest corrective patch needed.
   - After any corrective patch, rerun only the necessary validation first, then confirm final status.
   - Do not broaden into a new milestone or opportunistic cleanup.

8. Decide
   - `READY FOR COMMIT/PUSH`
   - `ONE LAST PATCH NEEDED`
   - `BLOCKED`

Output:
A) Local handoff result
- retrieval method used
- local branch now active
- whether pre-existing local changes were protected
- current git status summary

B) Verification verdict
- `READY FOR COMMIT/PUSH`
- `ONE LAST PATCH NEEDED`
- `BLOCKED`

C) Verification matrix
- control-plane coherence
- adapter coherence if relevant
- local environment/bootstrap
- validation scripts
- milestone-specific checks
- `check-fast`
- `check-changed`
- `check-full`
- runtime/build/test status if relevant

D) Validation performed
- exact commands run
- pass/fail result for each

E) Remaining blocker if any
- exact blocker only
- whether it is a real ship blocker or just follow-up hygiene

F) Final recommendation
- concise recommendation for the next action

G) Short summary
- brief operational summary of current repo state

H) Next suggested prompt

Next suggested prompt rules:
- If `READY FOR COMMIT/PUSH`:
  `07A-commit-push.md`
- If `ONE LAST PATCH NEEDED`:
  `04-blocker-patch.md`
- If `BLOCKED`:
  `No next prompt needed.`
