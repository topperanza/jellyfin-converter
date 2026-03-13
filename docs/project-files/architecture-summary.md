# Architecture Summary

## Layer framing
1. Core conversion engine (`scripts/jellyfin_converter.sh`, `scripts/lib/*`)
2. Safety/state layer (gates, verification-before-delete, processed tracking, churn guardrails)
3. CLI surface (canonical execution path)
4. Thin local GUI layer (operator convenience over canonical core)
5. Packaging/distribution layer (release assets, cross-platform operator install)
6. Validation layer (risk-focused checks then broader suite)
7. Control-plane layer (`docs/codex/*`, contributor process only)

## Core flow
1. Scan local media.
2. Probe streams.
3. Apply deterministic stream-selection and mapping policy.
4. Write MKV-first output.
5. Verify output.
6. Optionally allow destructive cleanup behind explicit confirmation.

## Safety + determinism invariants
- `dry-run` default and delete-off default.
- Explicit confirmation for destructive actions.
- Verification before destructive cleanup.
- Repeat-run safety via `logs/.processed` tracking and lock protection.
- Output-root exclusion guardrails to prevent recursive churn.
