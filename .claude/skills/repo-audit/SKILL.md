---
name: repo-audit
description: Recovery-only audit to assess milestone state, control-plane coherence, and whether the repo can return to standard workflow
---

> Canonical source: docs/codex/usage-prompts/000-repo-audit.md

# 000-repo-audit.md

Review-only task for the current repository.

Goal:
Perform a full repository audit to determine actual milestone state, control-plane truth, release-flow health, and whether the repository is safe to return to the standard milestone workflow.

This is a recovery audit, not the default milestone gate.

Hard rules:
- Do NOT implement changes.
- Do NOT use this prompt as the normal milestone gate.
- Prefer exact file references over generic advice.
- Treat `docs/project-files/*` as downstream export only unless the canonical workflow docs say otherwise.
- If something cannot be verified, say `NOT EVIDENCED`.

Audit scope:
Determine:
- actual milestone position
- docs/code/runtime drift
- validation truth
- control-plane coherence
- prompt-pack health
- adapter-file coherence
- release-flow health
- tag/version consistency
- broken internal links / broken file references
- whether the repo can safely return to standard milestone flow

Stable core that must remain intact unless direct repository evidence shows regression:
- source-of-truth hierarchy:
  1. code/tests/runtime/config
  2. `docs/agent-workflow/*` if present
  3. `docs/codex/*`
  4. README / architecture / release docs
  5. `docs/project-files/*`
- `AGENTS.md` and `CLAUDE.md` are adapters, not the primary source of truth
- `docs/project-files/*` is downstream/export-only by default
- milestone gate is contract-scoped
- blocker-closure is narrow
- full repo audit is recovery-only
- canonical validation order:
  1. milestone-specific validation
  2. `bash scripts/check-fast.sh`
  3. `bash scripts/check-changed.sh` if present and relevant
  4. `bash scripts/check-full.sh` only if justified
- local vs remote routing model remains intact
- automations remain app-managed, not repo-managed

Path discovery requirements:
1. Identify canonical shared workflow docs under `docs/agent-workflow/` if present
2. Identify `[CODEX_DOCS_DIR]`
3. Identify canonical `[PROMPTS_DIR]`
4. Identify whether duplicate prompt directories exist
5. Identify whether docs reference nonexistent or moved prompt paths
6. Identify whether `AGENTS.md` / `CLAUDE.md` drift from canonical workflow docs

Inspect first:
- `README.md`
- `CONTRIBUTING.md` if present
- `AGENTS.md` if present
- `CLAUDE.md` if present
- `docs/agent-workflow/*` if present
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- `docs/codex/CLOUD_ENV_CHECKLIST.md`
- `docs/codex/WORKFLOW_VERSION.md`
- `docs/project-files/` if present
- `.agents/skills/*` if present
- `.claude/skills/*` if present
- `docs/codex/usage-prompts/` or canonical `[PROMPTS_DIR]`
- any duplicate prompt directories
- `scripts/codex/setup.sh`
- `scripts/codex/maintenance.sh`
- `scripts/codex/check-workflow-conformance.sh`
- `scripts/check-fast.sh`
- `scripts/check-changed.sh` if present
- `scripts/check-full.sh` if present
- `CHANGELOG.md` if present
- relevant source/test/config/build files
- `.github/workflows/*` if present
- local git tags / release metadata if available

Required procedure:
1. Determine actual milestone position
2. Assess docs/code/runtime drift
3. Assess validation truth
4. Assess control-plane coherence
5. Assess prompt-pack coherence
6. Assess adapter coherence
7. Assess release-flow coherence
8. Assess tag/version consistency
9. Assess broken links / broken file references
10. Assess whether the repository can return to standard milestone flow

Run / inspect at minimum:
- `find . -maxdepth 6` for control-plane and prompt files
- grep or equivalent checks for prompt-path references across docs
- `bash scripts/codex/check-workflow-conformance.sh` if present
- `bash scripts/check-fast.sh` if present
- `bash scripts/check-changed.sh` if present and relevant
- `bash scripts/check-full.sh` only if justified
- inspect `.github/workflows/*` if present
- inspect git tags locally if available

Output:
A) Repository milestone position
B) Audit matrix
C) Critical drift / blockers
D) Recovery plan
E) Final recommendation
F) Next suggested prompt

Use statuses only:
- PASS
- PARTIAL
- BLOCKED
- CONCERN
- NOT EVIDENCED

Next suggested prompt rules:
- If the repo can return to normal flow and the next milestone is clear:
  `01-next-milestone-planner.md`
- If direct blockers need repair first:
  `04-blocker-patch.md`
- If recovery status is still too unclear:
  `No next prompt needed.`
