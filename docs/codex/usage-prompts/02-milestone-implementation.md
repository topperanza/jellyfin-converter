# 02-milestone-implementation.md

Implementation task for the current repository.

Goal:
Implement exactly one milestone-sized change according to the repository control plane and current milestone contract.

Hard rules:
- Do NOT redesign the repository.
- Do NOT broaden scope beyond the selected milestone.
- Do NOT reopen unrelated completed milestones without direct regression evidence.
- Keep diffs narrow and review-friendly.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` to update only the documentation that is required for this milestone.
- Update canonical shared docs first if they exist; update `AGENTS.md` / `CLAUDE.md` only when the milestone directly changes adapter-facing behavior.
- Treat `docs/project-files/*` as downstream export only unless explicitly required.

Inspect first:
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- relevant source/test/config/build files

Required procedure:
1. Restate the milestone contract
2. Implement only that scope
3. Run milestone-specific validation first
4. Run `bash scripts/check-fast.sh`
5. Run `bash scripts/check-changed.sh` if present and relevant
6. Run `bash scripts/check-full.sh` only if justified
7. Update only required docs/adapters/exports according to `DOC_SYNC_MATRIX.md` and the canonical workflow docs
8. Return a concise implementation summary

Output:
A) Milestone contract
B) Files changed
C) Validation performed
D) Docs/adapters/exports updated
E) Follow-ups
F) Completion status
G) Next suggested prompt

Next suggested prompt:
- `03-milestone-gate.md`