# Repo Overview

## Purpose
Deterministic local media conversion pipeline that outputs Jellyfin-compatible files while preserving originals by default.

## Primary source of truth
1. Code and tests (`scripts/`, `tests/`)
2. Runtime/config contracts (`run.sh`, env vars, CLI docs)
3. Codex control-plane docs (`docs/codex/*`)
4. Downstream summary layer (`docs/project-files/*`)

## Control-plane documents
- `docs/codex/PLAN.md`: milestone contracts, scope, completion criteria.
- `docs/codex/STATUS.md`: active milestone state and validation evidence.
- `docs/codex/RUNBOOK.md`: operational loop and handoff/checkpoint routine.
- `docs/codex/DOC_SYNC_MATRIX.md`: blocking vs non-blocking documentation sync rules.

## Validation entrypoints
1. `bash scripts/check-fast.sh`
2. `bash scripts/check-changed.sh <base-ref>` (when useful)
3. `bash scripts/check-full.sh`

## High-risk implementation paths
- ffmpeg command generation
- codec/container selection
- stream mapping
- subtitle/metadata handling
- output verification
