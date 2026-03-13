# Codex Long-Run Plan (Phase: product realignment complete, runtime confidence next)

_Last refreshed: 2026-03-13_

Milestone closure rule: milestone completion is determined by the milestone contract plus blocking rules in `docs/codex/DOC_SYNC_MATRIX.md`; record non-blocking documentation hygiene as follow-ups without blocking advancement.

## Canonical validation order (applies to every milestone)
1. Run narrow milestone-specific validation first.
2. Run `bash scripts/check-fast.sh`.
3. Run `bash scripts/check-changed.sh` if present and relevant.
4. Run `bash scripts/check-full.sh` only if justified by changed scope/risk.

## Milestone sequence

### Milestone 0 (ID: MILESTONE-0) — Scope + release narrative alignment
- **Objective:** Align product-facing and control-plane docs to a single approved product definition.
- **Scope / files:** `README.md`, `docs/scope.md`, `docs/architecture.md`, `docs/NEXT_STEPS.md`, `CHANGELOG.md`, `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, and required `docs/project-files/*` summaries.
- **Commands:**
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
- **Completion criteria:** v1/v1.1/v2 boundaries, safety invariants, layer framing, and next runtime-focused milestone direction are consistent across docs.
- **Risks / rollback:** documentation drift or mixed terminology; rollback by reverting milestone-local doc edits.
- **Checkpoint update:** record gate evidence and next-step prompt in status/checkpoint.

### Milestone 1 (ID: MILESTONE-1) — High-risk runtime validation contract
- **Objective:** Define a concrete runtime confidence contract for high-risk stream-selection/subtitle/ffmpeg mapping paths.
- **Scope / files:** `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, relevant runbook/checkpoint docs, and targeted runtime-validation planning docs.
- **Commands:**
  - narrow planning checks for changed docs/contracts
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
- **Completion criteria:** agreed representative edge-case matrix and validation expectations are explicit, test-targeted, and ready for runtime implementation milestones.
- **Risks / rollback:** over-broad matrix or unclear ownership; rollback by narrowing contract to risk-focused representative cases.
- **Checkpoint update:** capture contract, open risks, and first implementation-ready runtime milestone.

### Milestone 2 (ID: MILESTONE-2) — Thin local GUI over canonical runtime
- **Objective:** Keep GUI framing/operator flow aligned with CLI canonical behavior.
- **Scope / files:** runtime + docs touched by GUI/runtime interface alignment.
- **Commands:** milestone-specific runtime checks, then standard validation order.
- **Completion criteria:** GUI remains thin/operator-oriented with no drift from canonical CLI contract.
- **Risks / rollback:** accidental consumer-GUI scope creep; rollback by restoring CLI-first boundaries.
- **Checkpoint update:** log boundary checks and contract parity evidence.

### Milestone 3 (ID: MILESTONE-3) — Packaging and cross-platform operator readiness
- **Objective:** Close v1 packaging/distribution readiness gaps for local operators.
- **Scope / files:** packaging scripts/config/docs and release-facing validation paths.
- **Commands:** milestone-specific packaging checks, then standard validation order (full checks when justified).
- **Completion criteria:** cross-platform operator install/use path is stable and documented.
- **Risks / rollback:** packaging regressions; rollback by reverting packaging-local changes and restoring known-good release contract.
- **Checkpoint update:** record packaging evidence, residual gaps, and release readiness delta.

### Milestone 4 (ID: MILESTONE-4) — v1 release gate
- **Objective:** Confirm the v1 production-usable bar and finalize release narrative alignment.
- **Scope / files:** release/version docs, checklist/status artifacts, and final gate evidence.
- **Commands:** milestone-specific release checks, `bash scripts/check-fast.sh`, `bash scripts/check-full.sh`.
- **Completion criteria:** safety defaults/gates, deterministic behavior, repeat-run safety, representative edge-case confidence, and docs/package alignment are all evidenced.
- **Risks / rollback:** unresolved high-risk behavior; rollback by deferring release and reopening targeted runtime milestones.
- **Checkpoint update:** record pass/fail gate outcome and follow-up actions.
