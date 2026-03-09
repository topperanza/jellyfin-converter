# Validation Summary

## Preferred validation order
1. `bash scripts/check-fast.sh`
2. `bash scripts/check-changed.sh <base-ref>` (when useful for scoped deltas)
3. `bash scripts/check-full.sh`

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
- `./tests/run.sh` (full suite)
- `bash scripts/check_bash32.sh`

Use before major handoff/release-sensitive checkpoints.

## Expensive or environment-dependent checks
- Full test suite is broader and slower than fast validation.
- `--self-check` path is dependency-sensitive (`ffmpeg`, `ffprobe`).
