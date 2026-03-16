# Agent Workflow

This directory is the **canonical shared workflow layer** for this repository.
It takes precedence over any agent-specific adapter file (`AGENTS.md`, `CLAUDE.md`, `.aider.conf.yml`).

## Control-plane discovery order

Read workflow truth in this order:

1. code / tests / runtime behavior / schemas / config
2. `docs/agent-workflow/*` ← **this directory** (canonical shared layer)
3. `docs/codex/*` (Codex control-plane layer — PLAN, STATUS, RUNBOOK, etc.)
4. `README.md` / architecture / release docs
5. `docs/project-files/*` (downstream export only — not authoritative)

If `docs/agent-workflow/*` is missing, treat `docs/codex/*` as the current control plane.

## Contents

| File | Purpose |
|---|---|
| `README.md` | This file — entry point and discovery order |
| `SOURCE_OF_TRUTH.md` | Where truth lives for each concern |
| `WORKFLOW_ORDER.md` | Standard workflow sequence encoded by the prompt pack |
| `PROMPT_PACK_MAP.md` | Codex prompt-pack index, intent, and old→new migration map |
| `NON_NEGOTIABLES.md` | Hard rules evidenced from the repo and prompt pack |
| `DUAL_AGENT_ALIGNMENT.md` | Codex + Claude + Aider role assignments and handoff points |

## Adapter files (not primary source of truth)

| File | Agent | Role |
|---|---|---|
| `AGENTS.md` | Codex | Thin Codex adapter — repo-specific invariants and env setup |
| `CLAUDE.md` | Claude | Thin Claude adapter — local-workflow entry and Claude-specific notes |
| `.aider.conf.yml` | Aider | Minimal config — read-only context references, no duplicated instructions |

## Downstream export (not authoritative)

- `docs/project-files/*` — export layer for ChatGPT Project uploads; keep factual and low-churn
- `docs/codex/DOC_SYNC_MATRIX.md` governs which updates are blocking vs. follow-up hygiene
