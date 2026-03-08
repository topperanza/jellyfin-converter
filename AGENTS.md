# AGENTS.md

Operational guidance for coding agents in this repository.

## Scope
- Applies to the entire repository.
- Prefer minimal, targeted diffs; do not refactor unrelated code.

## Project invariants (source of truth)
- Runtime is Bash (must stay Bash 3.2 compatible).
- Entry points are `run.sh`, `scripts/jellyfin_converter.sh`, and `install.sh`.
- Keep dry-run-first behavior and conversion safety checks intact.
- Preserve idempotence (`logs/.processed`) and current `converted/` handling/exclusions.
- Optimize for deterministic conversion outputs; originals stay untouched unless explicit delete flags are enabled.

## Tooling preferences
- Use existing shell tooling; do not introduce new package managers/frameworks.
- Required runtime tools: `ffmpeg`, `ffprobe`, `find`, `df`.
- Optional tooling: `shellcheck` (run if present).
- Codex container entry commands:
  - Setup: `bash scripts/codex/setup.sh`
  - Maintenance: `bash scripts/codex/maintenance.sh`

## Validation commands (preferred order)
1. `bash -n scripts/jellyfin_converter.sh`
2. `./run.sh --self-check`
3. `./tests/run.sh tests/suite_parser.sh`
4. `./tests/run.sh`

Also run `scripts/check_bash32.sh` when shell files change broadly.

## Long-task checkpoints
- Milestone workflow: `docs/codex-milestones.md`.
- Store checkpoint notes in `.codex/checkpoints/MILESTONE-<n>.md`.
- Each checkpoint must record: files changed, commands run, results, risks/next step.

## Safety and hygiene
- Never commit secrets/tokens or machine-local credentials.
- No unrelated formatting churn.
- Update docs only when behavior or operator workflow changes.
- Keep release/integrity expectations intact (`release/check-release.sh`, installer checksum flow).
