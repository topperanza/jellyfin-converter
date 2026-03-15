# Source of Truth — Discovery Order

Use this order when reading workflow truth. Higher items win over lower items.

## Discovery order

1. **Code / tests / runtime behavior / schemas / config**
   - The repo implementation, test suites, and config files define actual behavior.
   - `scripts/jellyfin_converter.sh`, `scripts/lib/`, `tests/`, `config/`

2. **`docs/agent-workflow/*`** (this directory)
   - Canonical shared workflow layer for all agents.
   - Defines milestone flow, validation order, hard constraints, and agent alignment.

3. **`docs/codex/*`**
   - Codex-facing control-plane layer.
   - Active milestone state: `docs/codex/STATUS.md`, `docs/codex/PLAN.md`
   - Operational procedures: `docs/codex/RUNBOOK.md`, `docs/codex/DOC_SYNC_MATRIX.md`
   - Prompt pack: `docs/codex/usage-prompts/`

4. **README / architecture / release docs**
   - `README.md`, `docs/architecture.md`, `docs/cli-contract-v1.md`, `docs/releases/`

5. **`docs/project-files/*`** — downstream/export-only
   - Generated for ChatGPT Project upload. Not a primary source of truth.
   - Do not use as workflow authority.

## Adapter files (not sources of truth)

| File | Role |
|------|------|
| `AGENTS.md` | Thin Codex adapter. Points to `docs/codex/*` and `docs/agent-workflow/*`. |
| `CLAUDE.md` | Thin Claude adapter. Points to `docs/agent-workflow/*` and `docs/codex/*`. |
| `.aider.conf.yml` | Aider runtime config. References canonical docs as read-only context. |

None of these adapter files are authoritative. When they conflict with the discovery order above, the discovery order wins.

## Session memory is not durable truth

Do not rely on agent session memory, conversation history, or prior task summaries as workflow truth. Always read from the repo.
