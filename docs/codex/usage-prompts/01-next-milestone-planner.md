# 01-next-milestone-planner.md

Planning task for the current repository.

Goal:
Identify the next milestone-sized unit of work that moves the repository forward while preserving the current control plane, validation order, anti-loop workflow, and dual-agent compatibility.

Hard rules:
- Do NOT implement changes.
- Do NOT broaden into a full repo redesign.
- Do NOT reopen completed milestone history without direct regression evidence.
- Use canonical workflow docs first:
  1. `docs/agent-workflow/*` if present
  2. `docs/codex/*`
- Use `DOC_SYNC_MATRIX.md` to determine which documentation surfaces are likely to matter.
- Treat `docs/project-files/*` as downstream export only unless explicitly required by the canonical workflow docs.

Inspect first:
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- relevant source/test/config files
- recent commits / current branch state if helpful

Required procedure:
1. Determine actual current milestone position
2. Identify the highest-leverage next milestone
3. Keep milestone size narrow, testable, and reviewable
4. Define:
   - objective
   - constraints
   - likely files/modules
   - validation plan
   - required canonical docs and required adapters
   - required exports per `DOC_SYNC_MATRIX.md`
   - success criteria
   - rollback notes if relevant

Output:
A) Current state summary
B) Recommended next milestone
C) Why this milestone now
D) Exact implementation scope
E) Validation plan
F) Required docs/adapters/exports
G) Success criteria
H) Risks / assumptions
I) Next suggested prompt

Next suggested prompt:
- `02-milestone-implementation.md`