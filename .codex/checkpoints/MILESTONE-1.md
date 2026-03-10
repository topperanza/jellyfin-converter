# Milestone 1: Validation workflow hardening
- Date: 2026-03-10
- Goal: tighten validation ergonomics for incremental runs without changing conversion behavior.
- Completion criteria: changed-file validation has clear base-ref behavior and remains Bash 3.2-safe.

## Files changed
- `scripts/check-changed.sh`
- `docs/codex/RUNBOOK.md`
- `.codex/checkpoints/MILESTONE-1.md`
- `docs/codex/STATUS.md`

## Commands run
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `bash scripts/check-full.sh`

## Results
- Pass: `bash scripts/check-fast.sh`
- Pass: `bash scripts/check-changed.sh HEAD~1`
- Pass: `bash scripts/check-full.sh`
- `scripts/check-changed.sh` supports explicit base ref input while defaulting safely for incremental usage.
- Bash 3.2 compatibility checks remain wired into changed/full validation flows.

## Milestone 2 pre-existing coverage snapshot
- Existing suites already cover part of discovery/selection risk surface:
  - `tests/suite_discovery.sh`
  - `tests/suite_selection.sh`
- MILESTONE-2 should target uncovered edge cases only and avoid duplicating currently validated scenarios.

## Risks / next step
- Risk: milestone naming ambiguity can recur if non-numbered closures are mixed into active plan tracking without explicit labeling.
- Next step: execute MILESTONE-2 by identifying uncovered subtitle/discovery edge cases, add focused tests, validate, and checkpoint.
