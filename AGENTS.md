# AGENTS.md — Codex Adapter

This file is a thin Codex adapter. Shared workflow rules live in `docs/agent-workflow/`.

## Canonical shared workflow layer

Read before working:
- `docs/agent-workflow/README.md` — overview and quick-start
- `docs/agent-workflow/WORKFLOW_ORDER.md` — milestone flow, validation order, routing
- `docs/agent-workflow/NON_NEGOTIABLES.md` — hard constraints (evidenced from this repo)
- `docs/agent-workflow/SOURCE_OF_TRUTH.md` — discovery order

## Codex control-plane (active milestone state)

Read in this order on session start:
1. `AGENTS.md` (this file)
2. `docs/codex/PLAN.md`
3. `docs/codex/STATUS.md`
4. `docs/codex/REPO_OVERVIEW.md`
5. `docs/codex/WORKFLOW_VERSION.md`
6. `docs/codex/DOC_SYNC_MATRIX.md`
7. Most recent `.codex/checkpoints/MILESTONE-<n>.md`

## Codex environment setup

Fresh session:
```bash
bash scripts/codex/setup.sh
```

Resumed session:
```bash
bash scripts/codex/maintenance.sh
```

Workflow conformance check:
```bash
bash scripts/codex/check-workflow-conformance.sh
```

## Prompt pack

Canonical location: `docs/codex/usage-prompts/`
See `docs/agent-workflow/PROMPT_PACK_MAP.md` for the full prompt-to-step map.

## Repo-specific high-risk paths

- ffmpeg command generation
- codec/container selection
- stream mapping
- metadata/subtitle handling
- output verification and deletion safety gates

Changes to these areas require focused validation of codec/container/duration/stream mapping behavior.
