# AGENTS.md

## Canonical workflow docs (read these first)

1. `docs/agent-workflow/README.md` — canonical shared workflow layer; takes precedence
2. `docs/codex/PLAN.md`, `STATUS.md`, `RUNBOOK.md`, `DOC_SYNC_MATRIX.md` — Codex control plane
3. This file — Codex-specific adapter (repo-specific invariants and env setup only)

See `docs/agent-workflow/TRIPLE_AGENT_ALIGNMENT.md` for full agent role map.

## Current task state
- HANDOFF.md
- PROJECT_CONTEXT.md

## Codex environment
- setup: `bash scripts/codex/setup.sh`
- maintenance: `bash scripts/codex/maintenance.sh`

## Validation order
1. narrow milestone-specific validation first
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` (only if present and useful)
4. `bash scripts/check-full.sh` (only if justified)

## Non-negotiables
See `docs/agent-workflow/NON_NEGOTIABLES.md`. Do not treat this file as the primary workflow manual.

## Repo-specific invariants
- Source of truth:
  - The repo's media conversion rules, output expectations, and tests define intended behavior.
- Primary workflow:
  - Deterministic media conversion pipeline for Jellyfin-compatible outputs.
- Validation specifics:
  - Prefer fast output validation first, then broader conversion/test paths.
  - Verify codec, container, duration, and stream mapping explicitly for changed paths.
- High-risk paths:
  - ffmpeg command generation
  - codec/container selection
  - stream mapping
  - metadata / subtitle handling
  - output verification
- Safety constraints:
  - Originals untouched.
  - Media transforms must be deterministic and reproducible.
  - Prefer explicit codec/container rules over implicit ffmpeg behavior.
