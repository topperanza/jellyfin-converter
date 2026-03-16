# Source of Truth

## Primary sources (authoritative)

| Source | What it governs |
|---|---|
| Code + tests + runtime scripts | Actual behavior and correctness |
| `docs/agent-workflow/*` | Shared workflow process, non-negotiables, agent roles |
| `docs/codex/PLAN.md` | Milestone contracts and sequence |
| `docs/codex/STATUS.md` | Current milestone state and gate evidence |
| `docs/codex/RUNBOOK.md` | Operational commands and execution sequence |
| `docs/codex/DOC_SYNC_MATRIX.md` | Which doc updates are blocking vs. follow-up |
| `docs/codex/WORKFLOW_VERSION.md` | Workflow version and canonical prompt-pack path |
| `docs/codex/usage-prompts/` | Codex-facing prompt pack (canonical prompt location) |

## Secondary sources (context, not authoritative)

| Source | What it provides |
|---|---|
| `README.md` | User-facing product summary |
| `docs/architecture.md` | Architecture overview |
| `docs/scope.md` | Product scope boundaries |
| `docs/NEXT_STEPS.md` | Near-term roadmap |
| `docs/project-files/*` | Downstream export for ChatGPT Project uploads |

## Adapter files (thin, not authoritative)

| File | Agent | Content policy |
|---|---|---|
| `AGENTS.md` | Codex | Thin — repo-specific invariants and env setup only |
| `CLAUDE.md` | Claude | Thin — Claude-specific entry point and minimal local notes |
| `.aider.conf.yml` | Aider | Config only — no duplicated workflow instructions |

## Hard constraint

Do not treat agent session memory, conversation history, or adapter files as
primary sources of truth. Truth lives in the repository files listed above.
