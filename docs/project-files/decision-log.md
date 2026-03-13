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
| 2026-03-13 | Lock v1 product framing to a single-operator, safety-first local converter with CLI-canonical execution and thin local GUI convenience. | Remove ambiguity between product scope, release narrative, and control-plane planning. | README/scope/architecture/roadmap/status docs must retain this boundary; future milestones optimize confidence and readiness, not platform expansion. | accepted |
| 2026-03-13 | Prioritize runtime-confidence milestone next (stream-selection/subtitle/ffmpeg mapping) before additional feature expansion. | High-risk media-selection paths define product trust and release safety. | Next active milestone planning and validation contracts focus on representative edge-case confidence. | accepted |
