# 07B-squash-merge.md

Merge / finalization task for the current repository.

Run this with a local-capable agent only.

Goal:
Safely finalize verified work by squash-merging the current non-main branch into `main`, pushing `main`, and deleting the merged branch when safe.

Workflow assumption:
- This is a solo-maintainer repository.
- Default finalization after successful verification is:
  commit validated work on the current branch -> push branch -> squash merge into `main` -> push `main`.
- Prefer squash merge for clean history unless the current branch is already `main`.
- Do not leave verified work stranded on a topic branch unless explicitly instructed.

Precondition:
- the current branch is not `main`
- the work on the current branch has already been validated and pushed
- the branch scope is intentional and ready to merge
- any required local verification has already passed

Hard rules:
- Do NOT do new implementation work.
- Do NOT broaden scope beyond the already-verified work.
- Do NOT rewrite history except for the intended squash merge.
- Do NOT force-push.
- Do NOT merge if the branch contains unrelated changes.
- Do NOT silently resolve suspicious scope drift by editing additional files.
- Do NOT proceed if merge conflicts require non-trivial manual reconciliation; stop and report instead.
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
1. Confirm the current branch is not `main`.
2. Fetch latest remote state.
3. Inspect working tree and stop if the repo is not in a safe merge state.
4. Compare current branch vs `origin/main`.
5. Confirm the diff is limited to the intended verified task scope.
6. Confirm the branch commit history is the expected work only.
7. Check out `main`.
8. Update local `main` safely from `origin/main`:
   - prefer `git pull --ff-only origin main`
9. Squash merge the verified branch into `main`.
10. Create a clean final commit message:
    - default format:
      `<area/scope>: <imperative summary>`
    - if the branch already has a clearly better validated summary, reuse it
11. Push updated `main` to origin.
12. Delete the merged branch locally and remotely if safe and normal for the repo workflow.
13. Return a concise final summary.

Merge decision rules:
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