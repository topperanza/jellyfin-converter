# AGENTS.md

Guidance for coding agents working in this repository.

## Scope
- This file applies to the entire repository.
- Prefer minimal, targeted changes that preserve existing behavior.

## Project Snapshot
- Project: `jellyfin-converter`
- Language/runtime: Bash (`bash` 3.2+ compatibility required)
- Entry points: `run.sh`, `scripts/jellyfin_converter.sh`, `install.sh`
- Core docs: `README.md`, `docs/cli-contract-v1.md`, `docs/architecture.md`, `docs/user-guide.md`

## Safety-Critical Expectations
- Keep defaults conservative (dry-run-first behavior).
- Do not weaken validation/delete safeguards.
- Preserve idempotence behavior (processed tracking in `logs/.processed`).
- Keep `converted/` output handling and scan exclusions intact unless explicitly requested.

## Coding Standards
- Write portable shell compatible with Bash 3.2.
- Avoid Bash 4+ only features (e.g., associative arrays, `mapfile`, `globstar`).
- Quote variables defensively and avoid word-splitting bugs.
- Prefer extending existing helpers in `scripts/lib/` over duplicating logic.
- Keep changes ASCII unless file content already requires otherwise.

## Validation Checklist
Run relevant checks after edits:

1. Syntax check:
```bash
bash -n scripts/jellyfin_converter.sh
```
2. Full test suite:
```bash
./tests/run.sh
```
3. Targeted suite (when appropriate):
```bash
./tests/run.sh tests/suite_parser.sh
```

If ShellCheck is available, run it on changed shell scripts.

## Change Discipline
- Update docs/examples when user-visible behavior or flags change.
- Keep release/integrity expectations intact (`release/check-release.sh`, installer/checksum flow).
- Do not commit unrelated refactors.
- If the worktree contains unrelated modifications, leave them untouched.

## Quick Navigation
- Main script: `scripts/jellyfin_converter.sh`
- Shared libs: `scripts/lib/*.sh`
- Tests: `tests/`
- Example env/config: `examples/`, `config/default_profiles.env`
