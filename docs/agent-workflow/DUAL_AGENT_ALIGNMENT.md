# Dual-Agent Alignment (Codex + Claude + Aider)

This repository operates with three agents across two environments.
This file defines each agent's role, primary reading list, and handoff points.

## Agent summary

| Agent | Environment | Primary role |
|---|---|---|
| Codex (cloud) | Cloud / remote | Planning, implementation, gate, blocker closure, control-plane docs, release prep |
| Claude Code | Local | Local verification, commit/push, tag/release, environment-sensitive fixes |
| Aider | Local | Targeted implementation patches, focused milestone-scoped code edits |

---

## Codex (cloud)

**When to use:** All cloud-capable work — planning, normal milestone implementation,
gate evaluation, blocker-closure checks, repo-wide audits, docs/control-plane updates,
release prep review.

**Primary reading list (in order):**
1. `docs/agent-workflow/*` (this directory)
2. `AGENTS.md`
3. `docs/codex/PLAN.md`
4. `docs/codex/STATUS.md`
5. `docs/codex/RUNBOOK.md`
6. `docs/codex/REPO_OVERVIEW.md`
7. `docs/codex/DOC_SYNC_MATRIX.md`
8. Most recent `.codex/checkpoints/MILESTONE-<n>.md`

**Prompt entry point:** `docs/codex/usage-prompts/0000-README.md`

**Validation order:**
1. Narrow milestone-specific validation
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` if present and relevant
4. `bash scripts/check-full.sh` only if justified

**Environment setup:**
- Fresh session: `bash scripts/codex/setup.sh`
- Resumed/warm session: `bash scripts/codex/maintenance.sh`

---

## Claude Code (local)

**When to use:** Local verification, final handoff confirmation, commit/push,
tag/release, environment-sensitive fixes that require real local tooling.

**Primary reading list (in order):**
1. `docs/agent-workflow/*` (this directory)
2. `CLAUDE.md`
3. `docs/codex/PLAN.md`
4. `docs/codex/STATUS.md`
5. `docs/codex/RUNBOOK.md`
6. `docs/codex/DOC_SYNC_MATRIX.md`

**Prompt entry point:** `docs/codex/usage-prompts/06A-local-handoff+verification.md`
or `06B-local-verification.md` (then `07A-commit-push.md`)

**Validation order:** Same as Codex — milestone-specific → check-fast → check-changed → check-full.

---

## Aider (local)

**When to use:** Targeted implementation patches for a specific milestone-scoped change,
especially for focused code edits where diff review is the primary need.
Aider does not replace Codex for planning, gating, or repo audits.

**Primary reading list:** Loaded via `.aider.conf.yml` read-only context:
1. `docs/agent-workflow/README.md`
2. `docs/agent-workflow/NON_NEGOTIABLES.md`
3. `docs/agent-workflow/WORKFLOW_ORDER.md`
4. `AGENTS.md`

**Aider config:** `.aider.conf.yml` — minimal, provider-agnostic. See that file for details.

**Hard constraints for Aider use:**
- Never auto-commit. Changes are committed explicitly after review.
- Run `bash scripts/check-fast.sh` after any Aider edit before committing.
- Do not run Aider for planning, gating, or control-plane doc work.
- API credentials must be in local `.env` (untracked) — never in `.aider.conf.yml`.
- Verify `aider --check-update` or equivalent is safe before first run.

---

## Handoff points

| From | To | Trigger | Prompt |
|---|---|---|---|
| Codex cloud | Claude Code | Gate passes; local verification needed | `06A-local-handoff+verification.md` |
| Codex cloud | Claude Code | Work already local; verify before commit | `06B-local-verification.md` |
| Codex cloud | Aider | Targeted code patch needed in local env | Direct Aider invocation against the committed branch |
| Aider | Claude Code | Patch complete; needs local verification + commit | `06B-local-verification.md` → `07A-commit-push.md` |
| Claude Code | Codex cloud | Next milestone planning after commit | `01-next-milestone-planner.md` |

---

## Canonical docs ownership

| File | Owner | Update trigger |
|---|---|---|
| `docs/agent-workflow/*` | Any agent | Workflow or role definition changes |
| `docs/codex/PLAN.md` | Codex (cloud) | Milestone contract changes |
| `docs/codex/STATUS.md` | Codex (cloud) | Gate evidence, current state |
| `docs/codex/RUNBOOK.md` | Codex (cloud) | Operational procedure changes |
| `AGENTS.md` | Codex (cloud) | Codex-specific invariant or env changes |
| `CLAUDE.md` | Claude Code / Codex | Claude-specific workflow changes |
| `.aider.conf.yml` | Local (Aider/Claude Code) | Aider config changes |
