# Codex Run Status

_Last updated: 2026-03-13_

## Current task snapshot
- Completed documentation realignment for product vision/scope/version boundary consistency.
- Product docs now present a narrow safety-first local conversion story with CLI canonical and thin local GUI framing.
- Control-plane docs now point to a runtime-focused next milestone centered on high-risk mapping confidence.

## Current milestone
- ID: MILESTONE-1
- Title: High-risk runtime validation contract
- Goal: define representative, risk-focused confidence requirements for stream-selection/subtitle/ffmpeg mapping behavior before runtime code changes.
- Completion criteria: milestone contract drafted and approved in plan/status artifacts with explicit validation expectations and non-goal boundaries.

## Last completed milestone
- ID: MILESTONE-0
- Goal: scope + release narrative alignment across user-facing and control-plane docs.
- Checkpoint: this status update + commit for documentation realignment.

## Files touched in MILESTONE-0
- `README.md`
- `docs/scope.md`
- `docs/architecture.md`
- `docs/NEXT_STEPS.md`
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/project-files/product-summary.md`
- `docs/project-files/architecture-summary.md`
- `docs/project-files/workflow-invariants.md`
- `docs/project-files/decision-log.md`
- `CHANGELOG.md`

## Validation evidence (MILESTONE-0)
- Pass: `bash scripts/check-fast.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- Note: `./run.sh --self-check` was skipped inside fast checks because `ffmpeg`/`ffprobe` are unavailable in this environment.

## Known risks / follow-ups
- Runtime confidence for high-risk stream-selection/subtitle/mapping paths still requires explicit milestone-level validation contract work (MILESTONE-1).
- GUI scope must continue to be described as thin/operator-only until runtime/UI evidence justifies broader claims.

## Next step
- Execute `MILESTONE-1` planning/review only (no runtime implementation yet): define validation matrix, acceptance criteria, and targeted test-entrypoint strategy for high-risk paths.
