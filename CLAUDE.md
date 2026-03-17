# CLAUDE.md

## Canonical workflow docs (read these first)

1. `docs/agent-workflow/README.md` — canonical shared workflow layer; takes precedence
2. `docs/codex/PLAN.md`, `STATUS.md`, `RUNBOOK.md`, `DOC_SYNC_MATRIX.md` — Codex control plane
3. This file — Claude Code adapter (local verification and commit/push entry point)

See `docs/agent-workflow/TRIPLE_AGENT_ALIGNMENT.md` for full agent role map.

## Current task state
- HANDOFF.md
- PROJECT_CONTEXT.md

## Purpose

Claude Code is the local agent for this repository.
Primary roles: local verification, final handoff confirmation, commit/push, tag/release,
and environment-sensitive fixes that require real local tooling.

## Entry points

- Bringing cloud work local: `docs/codex/usage-prompts/06A-local-handoff+verification.md`
- Verifying already-local work: `docs/codex/usage-prompts/06B-local-verification.md`
- Commit and push: `docs/codex/usage-prompts/07A-commit-push.md`
- Tag and release: `docs/codex/usage-prompts/09-tag&release.md`

## Repo-specific notes

- Runtime: Bash CLI (`run.sh`, `scripts/jellyfin_converter.sh`); requires `ffmpeg` + `ffprobe` for conversion
- Test harness: `./tests/run.sh <suite>`
- Workflow conformance: `bash scripts/codex/check-workflow-conformance.sh`
- Target environment: macOS/Linux, Bash 3.2+
- High-risk paths: ffmpeg command generation, codec/container selection, stream mapping, subtitle/metadata handling

## Hard rules

See `docs/agent-workflow/NON_NEGOTIABLES.md` for the full list.
