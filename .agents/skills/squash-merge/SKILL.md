---
name: squash-merge
description: Squash-merge a verified non-main branch into main, push, and clean up the merged branch
---

> Canonical source: docs/codex/usage-prompts/07B-squash-merge.md

Precondition: run in a local environment with git, remote access, and the working repo checked out.

# 07B-squash-merge.md

Merge / finalization task for the current repository.

Run this with a local-capable agent only.

Goal:
Safely finalize verified work by squash-merging the current non-main branch into `main`, pushing `main`, and deleting the merged branch when safe.

Workflow mode:
Detect from `docs/codex/REPO_OVERVIEW.md` → `## Workflow Mode`. If absent, default to `solo-direct-push`.

- `solo-direct-push`: squash merge the current branch into `main` locally, push `main`, delete the merged branch.
  - Prefer squash merge for clean history unless the current branch is already `main`.
  - Do not leave verified work stranded on a topic branch unless explicitly instructed.
- `protected/team`: this prompt does not apply. Squash merge is performed via PR in the remote.
  - Stop here and report: `Workflow mode is protected/team — squash merge via PR only. This prompt does not apply.`

Precondition:
- the current branch is not `main`
- the work on the current branch has already been validated and pushed
- the branch scope is intentional and ready to merge
- any required local verification has already passed
- workflow mode is `solo-direct-push` (if `protected/team`, stop immediately)

Hard rules:
- Do NOT do new implementation work.
- Do NOT broaden scope beyond the already-verified work.
- Do NOT rewrite history except for the intended squash merge.
- Do NOT force-push.
- Do NOT merge if the branch contains unrelated changes.
- Do NOT silently resolve suspicious scope drift by editing additional files.
- Do NOT proceed if merge conflicts require non-trivial manual reconciliation; stop and report instead.
- Do NOT run this prompt if workflow mode is `protected/team`.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`

Inspect first:
- `git status --porcelain=v1 -b`
- `git branch --show-current`
- `git fetch origin`
- `git diff --name-status origin/main...HEAD`
- `git diff --stat origin/main...HEAD`
- `git log --oneline origin/main..HEAD`
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/DOC_SYNC_MATRIX.md`

Required procedure:
1. Read workflow mode from `docs/codex/REPO_OVERVIEW.md`. If `protected/team`, stop and report.
2. Confirm the current branch is not `main`.
3. Fetch latest remote state.
4. Inspect working tree and stop if the repo is not in a safe merge state.
5. Compare current branch vs `origin/main`.
6. Confirm the diff is limited to the intended verified task scope.
7. Confirm the branch commit history is the expected work only.
8. Check out `main`.
9. Update local `main` safely from `origin/main`:
   - prefer `git pull --ff-only origin main`
10. Squash merge the verified branch into `main`.
11. Create a clean final commit message:
    - default format:
      `<area/scope>: <imperative summary>`
    - if the branch already has a clearly better validated summary, reuse it
12. Push updated `main` to origin.
13. Delete the merged branch locally and remotely if safe and normal for the repo workflow.
14. Return a concise final summary.

Merge decision rules:
- If workflow mode is `protected/team`, stop and report immediately.
- If the branch diff against `origin/main` contains unrelated files, stop and report the blocker.
- If the branch has merge conflicts that require more than tiny mechanical resolution, stop and report the blocker.
- If the repository is already on `main`, do not run this prompt; report that `07A` should have ended the workflow.

Output:
A) Target
- repo
- merged branch
- destination branch (`main`)

B) Scope check
- files included in merge scope
- confirmation that the scope matched the verified task

C) Merge result
- squash merge status
- final commit SHA on `main`
- final commit message

D) Push result
- confirmation that `origin/main` was updated successfully

E) Branch cleanup
- whether local branch was deleted
- whether remote branch was deleted

F) Leftovers
- any precise blocker or remaining manual follow-up

G) Next suggested prompt
- If normal milestone work is now fully finalized:
  `No next prompt needed.`
- If the merged result is release-ready and release-prep has already passed:
  `09-tag&release.md`
