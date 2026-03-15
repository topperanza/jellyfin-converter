# Agent Workflow — Canonical Shared Layer

This directory is the canonical shared workflow layer for all agents working in this repository (Codex, Claude, Aider, or any future agent).

## What lives here

| File | Purpose |
|------|---------|
| `SOURCE_OF_TRUTH.md` | Discovery order for workflow truth; what lives where |
| `WORKFLOW_ORDER.md` | Canonical milestone flow, validation order, and routing rules |
| `NON_NEGOTIABLES.md` | Hard rules evidenced by repo control-plane files |
| `DUAL_AGENT_ALIGNMENT.md` | How Codex, Claude, and Aider relate to the shared layer |
| `PROMPT_PACK_MAP.md` | Maps `docs/codex/usage-prompts/` prompts to workflow steps |

## What does NOT live here

- **`docs/codex/*`** — Codex-facing control-plane (PLAN, STATUS, RUNBOOK, DOC_SYNC_MATRIX, prompt pack). Still authoritative for active milestone state and Codex-specific operational guidance.
- **`AGENTS.md`** — Thin Codex adapter; points here and to `docs/codex/*`.
- **`CLAUDE.md`** — Thin Claude adapter; points here.
- **`.aider.conf.yml`** — Aider runtime config; points here as read-only context.
- **`docs/project-files/*`** — Downstream export only (ChatGPT Project upload). Not a source of truth.

## Quick start for any agent

1. Read `docs/agent-workflow/SOURCE_OF_TRUTH.md` to understand the trust hierarchy.
2. Read `docs/agent-workflow/WORKFLOW_ORDER.md` for the correct milestone flow and validation sequence.
3. Read `docs/agent-workflow/NON_NEGOTIABLES.md` for hard constraints.
4. For active milestone state, read `docs/codex/STATUS.md` and `docs/codex/PLAN.md`.
5. For Codex-specific operational guidance, read `docs/codex/RUNBOOK.md`.
