# Recovery Runbook

## Interrupted run
1. Keep `DELETE=0` until rerun confidence is confirmed.
2. Re-run with same scan root; `.processed` entries skip already completed sources.
3. Investigate any partially written outputs (invalid files are removed by the converter).

## `.processed` and lock handling
- Processed marker file: `logs/.processed`
- Lock path: `logs/.processed.lock`
- If an abnormal termination leaves stale state, ensure no converter process is active, then remove only stale lock artifacts.

## Duplicate/unsafe operations prevention
- Do not enable `DELETE=1` during incident recovery.
- Keep `DELETE_SIDECARS=0` unless sidecar anchoring has been validated for the affected directory.
