# CLAUDE.md — Claude Adapter

This file is a thin Claude adapter. Shared workflow rules live in `docs/agent-workflow/`.

## Canonical shared workflow layer

Read before working:
- `docs/agent-workflow/README.md` — overview and quick-start
- `docs/agent-workflow/WORKFLOW_ORDER.md` — milestone flow, validation order, routing
- `docs/agent-workflow/NON_NEGOTIABLES.md` — hard constraints (evidenced from this repo)
- `docs/agent-workflow/SOURCE_OF_TRUTH.md` — discovery order

## Active milestone state

- `docs/codex/PLAN.md` — milestone roadmap and contracts
- `docs/codex/STATUS.md` — current milestone state and evidence
- `docs/codex/RUNBOOK.md` — operational procedures and command set
- `docs/codex/DOC_SYNC_MATRIX.md` — which doc updates block milestone gate

## Claude-specific notes

- No proprietary setup script. Run `bash scripts/check-fast.sh` as a sanity check on session start.
- Commit/push and tag/release require a local environment with git push credentials (same as Codex Local app routing — see `docs/agent-workflow/WORKFLOW_ORDER.md`).
- `.claude/rules/` is not used in this repository; all rules are in `docs/agent-workflow/NON_NEGOTIABLES.md`.
- Agent skills for common workflow steps are in `.agents/skills/`.
