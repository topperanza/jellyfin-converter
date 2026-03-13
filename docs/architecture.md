# Architecture & Layer Boundaries

## Product architecture framing
`jellyfin-converter` is intentionally narrow and local-first. The architecture is organized around deterministic conversion behavior and safety gates, with the CLI as the canonical surface.

## Layer model

### 1) Core conversion engine
- Canonical implementation: `scripts/jellyfin_converter.sh` plus `scripts/lib/*`.
- Responsibilities:
  - media discovery
  - ffprobe stream inspection
  - explicit codec/container/stream mapping decisions
  - ffmpeg command generation for MKV-first outputs

### 2) Safety + state layer
- Safety defaults and destructive-action gates (`DRY_RUN`, delete off by default, confirmation flow).
- Verification-before-cleanup contract.
- Processed tracking (`logs/.processed`) and lock coordination for repeat-run safety.
- Output-path exclusion/guardrails to avoid recursive churn.

### 3) CLI surface (canonical)
- `run.sh` and CLI/env contract in `docs/cli-contract-v1.md`.
- Primary operator control path for v1 behavior and troubleshooting.

### 4) Thin local GUI layer
- Optional local operator convenience layer over canonical runtime behavior.
- Not a consumer-product pivot and not a replacement for CLI contract authority.

### 5) Packaging/distribution layer
- Release artifacts (`release.tar.gz`, `checksums.txt`, `install.sh`).
- Cross-platform operator readiness for macOS/Linux.

### 6) Validation layer
- Focused high-risk validation first, then broader checks.
- Repo entrypoints: `scripts/check-fast.sh`, `scripts/check-changed.sh`, `scripts/check-full.sh`.
- Risk focus: stream-selection, subtitle/audio mapping, ffmpeg command construction, and output verification.

### 7) Control-plane layer (contributors only)
- Milestone process, gating, and status tracking in `docs/codex/*`.
- Purpose: contributor workflow reliability.
- This layer is intentionally separate from product scope.

## Safety invariants
- dry-run default
- delete-off default
- explicit confirmation for destructive actions
- verification before destructive cleanup
- deterministic stream-selection/mapping behavior
- repeat-run safety via processed tracking
- recursive output churn guardrails
