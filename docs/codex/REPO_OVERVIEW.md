# Repo Overview

## Repo purpose
`jellyfin-converter` is a deterministic local CLI pipeline that converts common video inputs into Jellyfin-friendly MKV outputs with conservative defaults and explicit safety controls.

## Stack and runtime model
| Area | Repo reality |
|---|---|
| Runtime | Bash-first CLI (`run.sh`, `scripts/jellyfin_converter.sh`) |
| Media tooling | `ffmpeg` + `ffprobe` required for real conversion/verification |
| Test harness | Shell test runner (`./tests/run.sh`) with suite-based scripts |
| Validation entrypoints | `scripts/check-fast.sh`, `scripts/check-changed.sh`, `scripts/check-full.sh` |
| Target environment | macOS/Linux, Bash 3.2+ |

## Primary subsystems
- CLI/runtime orchestration: `run.sh`, `scripts/jellyfin_converter.sh`
- Conversion primitives: `scripts/lib/ffmpeg.sh`, `scripts/lib/ffprobe.sh`, `scripts/lib/media_filters.sh`
- IO and process guards: `scripts/lib/io.sh`, `scripts/lib/process.sh`, `scripts/lib/compat.sh`
- Validation + gates: `scripts/check-*.sh`, `tests/` suites and fixtures
- Codex control plane: `docs/codex/PLAN.md`, `STATUS.md`, `RUNBOOK.md`, `WORKFLOW_VERSION.md`, `DOC_SYNC_MATRIX.md`, and `scripts/codex/check-workflow-conformance.sh`

## Safety model and invariants
- Originals remain untouched by default; destructive flows are explicit and gated.
- Media transforms should be deterministic/reproducible.
- Explicit codec/container/stream mapping policy is preferred over implicit ffmpeg behavior.
- High-risk changes require focused validation of codec/container/duration/stream mapping behavior.

## Milestone numbering and naming scheme
- Active implementation milestones use numbered IDs from plan order: `MILESTONE-<n>`.
- Exceptional documentation-only closure IDs may be non-numbered (for example `MILESTONE-docs-project-files`) and must be tracked as additional closures in `docs/codex/STATUS.md`, not as active implementation milestones.

## Milestone completion rule
Milestone completion is determined by the milestone contract plus the blocking rules in docs/codex/DOC_SYNC_MATRIX.md. Non-blocking documentation hygiene items should be recorded as follow-ups and must not automatically block advancement.

## Standard validation order
1. Run narrow milestone-specific validation first.
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` (only when present/useful for changed scope)
4. `bash scripts/check-full.sh` (only if justified)

## High-risk areas
- ffmpeg command generation
- codec/container selection
- stream mapping
- subtitle and metadata handling
- output verification and deletion safety gates

## docs/project-files convention
`docs/project-files/` is a concise downstream export layer for the repository's ChatGPT Project upload context. Keep it low-churn and factual. Do not treat it as the primary control-plane source of truth.

## Operator workflow (Codex Cloud and Codex app)
1. Inspect current state (`AGENTS.md`, `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, `docs/codex/RUNBOOK.md`).
2. Confirm active milestone in `PLAN.md`.
3. Implement one coherent milestone.
4. Validate in standard order.
5. Sync required docs using `docs/codex/DOC_SYNC_MATRIX.md`.
6. Apply milestone gate + record status/follow-ups in `docs/codex/STATUS.md`.
7. If blocked, fix blockers only and run a targeted blocker-closure check.
8. Write/update checkpoint (`.codex/checkpoints/MILESTONE-<id>.md`).
9. Commit/push.
