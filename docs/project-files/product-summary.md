# Product Summary

## What this repository does
Provides a stable local CLI and Bash pipeline to convert common video sources into Jellyfin-friendly MKV outputs with conservative defaults and safety controls.

## Main user/operator outcome
- Produce playback-compatible outputs for Jellyfin.
- Keep originals by default, with deletion only when explicitly enabled and validated.
- Run deterministic conversions that can be resumed safely.

## Current scope
- Local conversion workflow via `run.sh` / `scripts/jellyfin_converter.sh`.
- Stable CLI contract (`docs/cli-contract-v1.md`) for flags, env vars, and exit codes.
- Release and validation workflow for macOS/Linux.
- Subtitle/audio selection, stream mapping, and output verification backed by tests.

## Explicit non-goals
- Not a media library manager or Jellyfin server plugin.
- Not a cloud conversion service.
- Not a GUI-first product in current repo scope.

## Quality bar / success criteria
- Deterministic behavior for identical inputs/configuration.
- Explicit codec/container/stream decisions over implicit ffmpeg behavior.
- Validation-first workflow (`scripts/check-fast.sh` before broader checks).
- Originals remain untouched unless deletion is explicitly enabled.
