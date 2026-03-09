# Decision Log

Purpose: compact ADR-style record for stable, cross-session decisions that affect implementation and operator expectations.

## Entry format
| Date (UTC) | Decision | Rationale | Impact | Status |
|---|---|---|---|---|
| YYYY-MM-DD | Short statement | Why this was chosen | What must stay aligned | proposed/accepted/superseded |

## Current entries
| Date (UTC) | Decision | Rationale | Impact | Status |
|---|---|---|---|---|
| 2026-03-09 | Maintain a curated `docs/project-files/` summary layer for ChatGPT Project uploads. | Keep future chats aligned with repo reality without loading full docs each time. | Milestone work must update affected summaries when behavior/contracts/process changes. | accepted |
| 2026-03-09 | Keep `docs/project-files/` concise and low-churn; do not duplicate full docs. | Reduce maintenance noise and drift against canonical deep-dive docs/tests. | Only stable summaries, invariants, handoff notes, and decisions belong in this layer. | accepted |
