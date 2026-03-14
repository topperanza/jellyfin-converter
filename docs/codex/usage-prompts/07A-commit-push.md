# 07A-commit-push

Commit / push task for the current repository.

Run this with a local-capable agent only.

Goal:
Commit and push the completed verified work safely, with milestone-aware tracking, explicit validation evidence, and no history rewriting.

Workflow assumption:
- This is a solo-maintainer repository.
- Verified work should not be left stranded on a topic branch.
- If the current branch is not `main`, the normal next step after this prompt is squash-merge finalization into `main` using `07B-squash-merge.md`.
- If the current branch is already `main`, this prompt may end the workflow directly.

Precondition:
- the milestone gate has passed, or blocker closure has confirmed `SAFE TO MOVE ON`
- if local verification was needed, it has already passed
- the current change set is intentionally scoped and ready to preserve

Hard rules:
- Do NOT force-push.
- Do NOT rewrite history.
- Do NOT amend old commits unless explicitly required and clearly reported.
- Do NOT create vague commit messages.
- Do NOT commit unrelated generated junk.
- Do NOT commit unvalidated work.
- Do NOT merge into `main` as part of this prompt unless the repository is already on `main`.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` to determine which tracking surfaces were required.
- Non-blocking documentation hygiene may remain as explicit follow-ups.
- `docs/project-files/*` is export-only and only required if `DOC_SYNC_MATRIX.md` says so.

Inspect first:
- `git status --porcelain=v1 -b`
- `git branch --show-current`
- `git diff --stat`
- `git diff --summary`
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- `docs/project-files/` if relevant
- relevant changed source files
- relevant changed tests

Required procedure:
1. Inspect branch and working tree.
2. Confirm whether the current branch is `main` or a non-main branch.
3. Verify required tracking/documentation surfaces using `DOC_SYNC_MATRIX.md`.
4. Run the lightest sufficient validation:
   - narrow checks first
   - `bash scripts/check-fast.sh`
   - `bash scripts/check-changed.sh` if present and relevant
   - `bash scripts/check-full.sh` only if justified
5. Review the final diff and ensure the scope matches the verified work.
6. Prepare commit grouping.
7. Write proper commit message(s):
   `<area/scope>: <imperative summary>`
8. Stage only intended files and commit.
9. Push safely:
   - if on a feature/topic branch: push current branch
   - if on `main`: push `main`
   - if no upstream: `git push -u origin <branch>`
10. Return a concise final summary.

Output:
A) Target
- repo
- current branch
- upstream branch if any

B) Artifacts
- files committed
- commit SHA
- commit message

C) Verification
- checks run
- result
- why the validation level was sufficient

D) Tracking surfaces
- required surfaces updated
- optional surfaces deferred

E) Leftovers
- uncommitted leftovers if any
- ignored/generated leftovers if any

F) Follow-ups
- explicit non-blocking follow-ups only

G) Next suggested prompt

Next suggested prompt rules:
- If the current branch is `main` and this is normal milestone work:
  `No next prompt needed.`
- If the current branch is `main` and the result is release-ready and release-prep already passed:
  `09-tag&release.md`
- If the current branch is not `main`:
  `07B-squash-merge.md`
- If the current branch is not `main` and the result is release-ready and release-prep already passed:
  `07B-squash-merge.md` then `09-tag&release.md`