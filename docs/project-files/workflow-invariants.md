# Workflow Invariants

## Safety rules
- Start from non-destructive mode (`DRY_RUN=1`, `DELETE=0`) unless intentionally overridden.
- Originals and sidecars are never deleted unless explicit delete flags are set.
- Destructive behavior remains opt-in and confirmation-gated unless skip-confirm is explicitly set.

## Determinism and reproducibility
- Conversion and selection outcomes must be deterministic for identical inputs and config.
- `.processed` tracking remains append-only and lock-protected.
- Prefer explicit codec/container/stream rules over implicit ffmpeg defaults.

## Mutation boundaries
- Source media are treated as immutable inputs.
- Generated outputs are written under `OUTROOT` (default `converted/` in scan root).
- `converted/` (or configured `OUTROOT`) is excluded from recursive discovery when in scan scope.

## Failure/reporting expectations
- Exit codes follow `docs/cli-contract-v1.md` mapping.
- Logs stay under `logs/` (or configured `LOG_DIR`) and remain operator-auditable.
- Preflight and validation failures should fail closed (no destructive follow-up).

## Cross-change invariants
- Tests and docs are the behavior contract; high-risk conversion changes require focused test coverage.
- Milestone changes that affect behavior/safety/validation must update `docs/project-files/*`.
