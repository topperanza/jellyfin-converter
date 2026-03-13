# Codex Run Status

_Last updated: 2026-03-14_

## Current task snapshot
- Completed **MILESTONE-1** as planning/review-only (no runtime code changes).
- Defined a representative high-risk runtime validation matrix for deterministic stream-selection, mixed-language subtitle/audio mapping, and ffmpeg mapping confidence.
- Locked explicit acceptance criteria, non-goals, validation entrypoint ordering, and evidence format for runtime implementation milestones.


## Planning refresh (2026-03-14)
- Reconfirmed actual milestone position: **MILESTONE-1 complete**, **MILESTONE-1A active**.
- Narrowed the next implementation pass to one reviewable M1A slice covering only M1-C01..M1-C04 (deterministic ordering, mixed-language forced/normal behavior, external/internal precedence, commentary/SDH determinism).
- Preserved control-plane and validation order: targeted suites first, then `bash scripts/check-fast.sh`, then `bash scripts/check-changed.sh HEAD~1`, and `bash scripts/check-full.sh` only if justified by changed runtime breadth/risk.
- Kept `docs/project-files/*` as downstream-only (no blocking updates expected unless milestone scope/workflow materially changes).

## Current milestone
- ID: MILESTONE-1A
- Title: Runtime implementation — mapping confidence tranche 1
- Goal: implement and validate matrix cases M1-C01..M1-C04 using targeted runtime/test updates only.
- Completion criteria: C01..C04 pass with explicit command + matrix evidence in status/checkpoint artifacts.

## Last completed milestone
- ID: MILESTONE-1
- Goal: ratify the high-risk runtime validation contract before runtime code changes.
- Gate result: **Pass (planning contract complete, implementation deferred by design).**

## Files touched in MILESTONE-1
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/project-files/validation-summary.md`
- `docs/project-files/workflow-invariants.md`
- `docs/project-files/decision-log.md`

## Validation evidence (MILESTONE-1)
- Pass (inspection-only): reviewed milestone contract alignment against existing v1 boundaries and current test/docs surfaces (`README.md`, `docs/scope.md`, `docs/architecture.md`, `docs/NEXT_STEPS.md`, `tests/suite_selection.sh`, `tests/suite_ffmpeg.sh`, `tests/test_subtitle_mapping.sh`, `tests/test_phase4_mapping.sh`, `tests/test_internal_subtitles.sh`).
- Skipped by milestone design: runtime test execution commands are defined but intentionally not run in this planning-only milestone.

## Ratified MILESTONE-1 contract summary

### Representative edge-case matrix
- **M1-C01:** deterministic tie-break ordering.
- **M1-C02:** mixed-language forced + normal retention/drop behavior.
- **M1-C03:** external/internal precedence (text vs bitmap).
- **M1-C04:** commentary + SDH deterministic handling.
- **M1-C05:** `und` language fallback determinism.
- **M1-C06:** audio/subtitle mapping coherence in ffmpeg mapping graph.
- **M1-C07:** subtitle disposition correctness (`forced/default/none`).

### Acceptance criteria + non-goals
- Criteria: matrix mapped to entrypoints/new-test gaps, explicit command ordering, explicit evidence schema, explicit non-goals, and execution-ready first runtime milestone.
- Non-goals: no runtime code changes, no broad fixture expansion, no product-scope broadening beyond v1 boundaries.

### Validation entrypoints/ordering
1. `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
2. `./tests/run.sh tests/test_subtitle_mapping.sh tests/test_phase4_mapping.sh tests/test_internal_subtitles.sh`
3. `bash scripts/check-fast.sh`
4. `bash scripts/check-changed.sh HEAD~1`
5. `bash scripts/check-full.sh` (only if justified by runtime breadth/risk)

### Evidence format
- Per command: exact command + pass/fail/skip with reason.
- Per matrix case: mapped test(s), expected/observed proof fragments (`-map`, `-disposition`, ordering), outcome.
- Environment notes: dependency limits and impact.
- Residual risks: uncovered matrix cases/flaky or non-deterministic signals.

## Known risks / follow-ups
- M1-C05..M1-C07 may require additional targeted tests after tranche-1 runtime changes; carry as explicit follow-ups if not fully closed in MILESTONE-1A.
- Preserve representative-matrix discipline to avoid broad, non-v1 test-surface expansion.

## Next step
- Execute `MILESTONE-1A` runtime implementation for M1-C01..M1-C04 only, using the ratified entrypoint ordering and evidence schema.
