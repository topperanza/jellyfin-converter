# Validation Summary

## Preferred validation order
1. Narrow milestone-specific validation first (suite/command depends on changed scope).
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh <base-ref>` (when useful for scoped deltas)
4. `bash scripts/check-full.sh`

## Runtime mapping-confidence contract (MILESTONE-1)
Representative matrix IDs:
- M1-C01 deterministic tie-break ordering
- M1-C02 mixed-language forced + normal behavior
- M1-C03 external/internal precedence (text vs bitmap)
- M1-C04 commentary + SDH handling
- M1-C05 `und` language fallback determinism
- M1-C06 audio/subtitle mapping coherence
- M1-C07 subtitle disposition correctness

Required targeted entrypoints before broad checks:
1. `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
2. `./tests/run.sh tests/test_subtitle_mapping.sh tests/test_phase4_mapping.sh tests/test_internal_subtitles.sh`
3. `bash scripts/check-fast.sh`
4. `bash scripts/check-changed.sh HEAD~1`
5. `bash scripts/check-full.sh` only when runtime breadth/risk justifies.

## Evidence format
For runtime milestones, status/checkpoint evidence must include:
- exact command + pass/fail/skip (with skip reason)
- matrix-case mapping to tests and proof fragments (`-map`, `-disposition`, ordering)
- environment notes (`ffmpeg`/`ffprobe` dependency impact)
- residual risk list for uncovered/flaky cases

## What fast validation covers
`scripts/check-fast.sh` runs:
- `bash -n scripts/jellyfin_converter.sh`
- `./tests/run.sh tests/suite_parser.sh`
- `./run.sh --self-check` when `ffmpeg` and `ffprobe` are available

Use this as default milestone validation and for doc/script touchpoints.

## What changed-file validation covers
`scripts/check-changed.sh` inspects git diff scope and conditionally runs:
- shell syntax checks
- parser suite
- Bash 3.2 compatibility checks

Best signal comes from an explicit base ref (example: `HEAD~1`).

## What full validation covers
`scripts/check-full.sh` runs:
- `bash scripts/check-fast.sh`
- `./tests/run.sh` (default suite set: `tests/suite_*.sh`)
- `bash scripts/check_bash32.sh`

Use before major handoff/release-sensitive checkpoints.

## Expensive or environment-dependent checks
- Default suite-set validation is broader and slower than fast validation.
- `--self-check` path is dependency-sensitive (`ffmpeg`, `ffprobe`).
