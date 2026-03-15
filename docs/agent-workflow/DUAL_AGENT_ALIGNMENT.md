# Triple-Agent Alignment — Codex, Claude, and Aider

This document describes how Codex, Claude, and Aider are aligned to the same canonical shared workflow layer in this repository.

## Canonical shared layer

All three agents read from `docs/agent-workflow/*` as the shared source of workflow truth. See `docs/agent-workflow/SOURCE_OF_TRUTH.md` for the full discovery order.

## Agent adapters

| Agent | Adapter file | Purpose |
|-------|-------------|---------|
| Codex | `AGENTS.md` | Thin adapter; Codex-specific setup commands and routing |
| Claude | `CLAUDE.md` | Thin adapter; Claude-specific entry notes |
| Aider | `.aider.conf.yml` | Runtime config; loads canonical docs as read-only context |

None of the adapter files duplicate the shared workflow. They point to it.

## Codex

**Adapter:** `AGENTS.md`

Codex reads `AGENTS.md` on session start. `AGENTS.md` points to:
- `docs/agent-workflow/` for shared workflow rules
- `docs/codex/PLAN.md` and `docs/codex/STATUS.md` for active milestone state
- `docs/codex/RUNBOOK.md` for operational procedures
- `docs/codex/usage-prompts/` for the prompt pack

Codex-specific concerns:
- Environment setup: `bash scripts/codex/setup.sh` (fresh) or `bash scripts/codex/maintenance.sh` (resumed)
- Workflow conformance check: `bash scripts/codex/check-workflow-conformance.sh`
- Prompt pack version tracked in `docs/codex/WORKFLOW_VERSION.md`

## Claude

**Adapter:** `CLAUDE.md`

Claude reads `CLAUDE.md` on session start. `CLAUDE.md` points to:
- `docs/agent-workflow/` for shared workflow rules
- `docs/codex/PLAN.md` and `docs/codex/STATUS.md` for active milestone state

Claude uses the same milestone flow and validation order as Codex. No separate workflow documentation for Claude; all workflow truth is in `docs/agent-workflow/`.

Claude-specific notes:
- No proprietary setup script; run `bash scripts/check-fast.sh` as a sanity check on session start.
- Use `docs/codex/RUNBOOK.md` for operational procedure details.
- Commit/push requires a local-capable environment (same as Codex Local app routing).

## Aider

**Adapter:** `.aider.conf.yml`

Aider reads `.aider.conf.yml` on startup. The config loads canonical docs as read-only context so Aider has workflow awareness without duplicating instructions in the config.

Aider-specific notes:
- Aider is repo-ready for remote/cloud use via API (ANTHROPIC_API_KEY or OPENAI_API_KEY from `.env`).
- See `.env.example` for required environment variable placeholders.
- Aider follows the same milestone flow and validation order as Codex and Claude.
- Aider runtime is not available in the cloud environment; local verification is the expected path. See `docs/codex/usage-prompts/06A-local-handoff+verification.md`.

Aider alignment with NON_NEGOTIABLES:
- All hard rules in `docs/agent-workflow/NON_NEGOTIABLES.md` apply equally to Aider sessions.
- Aider must not commit secrets or bypass safety gates.
- Aider must run validation in the canonical order before committing.

## Shared rules (apply to all three agents)

All three agents are bound by `docs/agent-workflow/NON_NEGOTIABLES.md`. Key shared rules:

- Keep diffs narrow and milestone-scoped.
- Do not rely on session memory as workflow truth; re-read from repo.
- Validate in canonical order before committing.
- Milestone completion requires PLAN contract + DOC_SYNC_MATRIX blocking rows satisfied.
- Non-blocking items must not block milestone gate.
- `docs/project-files/*` is downstream export only.

## Workflow alignment guarantee

If all three agents follow `docs/agent-workflow/WORKFLOW_ORDER.md` and `docs/agent-workflow/NON_NEGOTIABLES.md`, they are aligned by construction. Adapter files add only agent-specific entry points, not separate workflow rules.
