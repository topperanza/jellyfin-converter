# Architecture Summary

## Top-level structure
- `scripts/jellyfin_converter.sh`: canonical conversion implementation.
- `run.sh`: local entrypoint wrapper.
- `scripts/lib/`: shared shell modules used by conversion flow.
- `config/default_profiles.env`: preset/profile defaults.
- `tests/`: shell harness + suites for parser, selection, ffmpeg safety, subtitles, and scenarios.
- `docs/`: user, architecture, CLI contract, runbooks, and Codex workflow.

## Core flow
1. Parse CLI/env configuration.
2. Discover candidate media files (with output/hidden-path exclusions by default).
3. Probe streams and decide remux vs transcode using explicit policy.
4. Build ffmpeg command with explicit codec/container/stream mapping.
5. Validate output and record success in `logs/.processed`.
6. Optional deletion path is gated by validation and explicit flags.

## Important boundaries
- Conversion logic lives in scripts; docs/tests define expected behavior.
- Output tree is separated from source tree and excluded from recursive rescans.
- `.processed` is append-only and lock-protected for parallel safety.
- Stable CLI contract is versioned in `docs/cli-contract-v1.md`.

## Higher-risk / higher-complexity areas
- ffmpeg command generation and codec/container selection.
- Stream mapping and subtitle/audio language handling.
- Delete-sidecar/original safety behavior.
- Preflight and output verification paths.
