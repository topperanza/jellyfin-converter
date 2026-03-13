# Codex Long-Run Plan (Phase: product realignment complete, runtime confidence next)

_Last refreshed: 2026-03-14_

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
- **Objective:** Lock a deterministic, v1-scoped runtime confidence contract for stream-selection determinism, mixed-language subtitle/audio mapping, and ffmpeg mapping correctness before any runtime code changes.
- **Scope / files:** planning/control-plane docs only (`docs/codex/PLAN.md`, `docs/codex/STATUS.md`, optional runbook updates, and concise `docs/project-files/*` sync artifacts). No runtime implementation.
- **Representative edge-case matrix (contract set):**

| Case ID | Risk focus | Representative scenario | Required assertions |
|---|---|---|---|
| M1-C01 | Deterministic tie-break | Equal-priority candidates (internal vs external, same language/slot) | Same input/config always yields same selected stream order + same `-map` output order.
| M1-C02 | Mixed-language forced + normal | `eng` + `ita` normal plus `rus` forced (internal/external mix) | Forced track preserved; wanted normal tracks preserved; non-forced non-wanted dropped.
| M1-C03 | External/internal precedence | External text vs internal bitmap in same language/slot | Text wins; bitmap retained only when policy explicitly allows it.
| M1-C04 | Commentary/SDH handling | Commentary and SDH combinations alongside primary tracks | Commentary retained per policy; SDH preference behavior is explicit and deterministic.
| M1-C05 | Undetermined language (`und`) | Internal `und` + titled track mixed with explicit language tracks | Fallback/ranking remains deterministic and policy-aligned; no random/position-based drift.
| M1-C06 | Audio/subtitle mapping coherence | Multiple audio tracks with language/title metadata and mapped subtitles | ffmpeg `-map` graph keeps expected audio + subtitle pairing without dropping required streams.
| M1-C07 | Disposition correctness | Forced + normal subtitle outputs together | `-disposition:s:*` flags match plan (forced/default/none) and remain stable across runs.

- **Acceptance criteria:**
  1. Matrix cases are mapped to exact current test entrypoints (or explicitly marked as new tests required in the next milestone).
  2. Validation order and command list are explicit and reproducible.
  3. Evidence format is defined (command, result, and artifacts required per case).
  4. Non-goals are explicit to prevent v1 scope creep.
  5. First runtime implementation milestone is fully defined and execution-ready.
- **Non-goals (for this milestone):**
  - No runtime behavior changes in `scripts/`.
  - No broad fixture expansion beyond the representative matrix contract.
  - No GUI/product-scope expansion beyond v1 CLI-canonical + thin local GUI framing.
- **Validation entrypoints and ordering (for runtime milestone execution):**
  1. **Targeted high-risk suites first:**
     - `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
     - `./tests/run.sh tests/test_subtitle_mapping.sh tests/test_phase4_mapping.sh tests/test_internal_subtitles.sh`
  2. **Then repo-fast gate:** `bash scripts/check-fast.sh`
  3. **Then delta-focused gate:** `bash scripts/check-changed.sh HEAD~1`
  4. **Run full only if justified by touched runtime breadth:** `bash scripts/check-full.sh`
- **Evidence format (required in STATUS/checkpoint for runtime execution):**
  - Per command: exact command, pass/fail, and short reason if skipped.
  - Per matrix case: mapped test(s), observed proof string(s) (for example key `-map` / `-disposition` fragments), and outcome.
  - Environment notes: dependency limitations (`ffmpeg`/`ffprobe`) and their impact.
  - Residual risk list: uncovered matrix rows or flaky/non-deterministic signals.
- **Risks / rollback:** matrix grows beyond representative scope or lacks executable mapping; rollback by reducing to the seven contract rows above and deferring extras to follow-up milestones.
- **Checkpoint update:** record ratified matrix, acceptance/non-goals, validation order/evidence contract, and promotion to first runtime implementation milestone.

### Milestone 1A (ID: MILESTONE-1A) — Runtime implementation: mapping confidence tranche 1
- **Objective:** Implement the minimum runtime/test changes required to satisfy M1-C01..M1-C04 determinism and mapping assertions.
- **Scope / files:** runtime stream-selection/mapping paths (`scripts/lib/media_filters.sh`, related CLI wiring if required) + targeted tests/fixtures only for C01..C04.
- **In scope:** deterministic tie-break ordering, mixed-language forced/normal retention, external/internal precedence correctness, commentary/SDH deterministic behavior.
- **Out of scope:** packaging, GUI changes, non-representative matrix expansion, release narrative changes.
- **Execution slice (narrow contract for next implementation pass):**
  1. **Deterministic ordering and tie-break audit (M1-C01):** update only ranking/tie logic and ordering assertions around `build_subtitle_plan` / mapping assembly (no policy expansion).
  2. **Mixed-language forced+normal retention (M1-C02):** ensure one forced + one normal slot behavior remains deterministic for wanted languages while preserving forced tracks for other languages.
  3. **External vs internal precedence clarity (M1-C03):** verify text-vs-bitmap and internal-vs-external precedence via config-aware scoring and selection assertions.
  4. **Commentary/SDH deterministic handling (M1-C04):** lock behavior using focused fixtures/assertions without broadening language or GUI scope.
- **Likely files/modules for M1A:**
  - Runtime: `scripts/lib/media_filters.sh`, `scripts/lib/process.sh` (only if required for map/disposition emission coherence).
  - Targeted tests: `tests/suite_selection.sh`, `tests/suite_ffmpeg.sh`, `tests/test_subtitle_mapping.sh`, `tests/test_phase4_mapping.sh`, `tests/test_internal_subtitles.sh`, and tightly scoped fixtures under `tests/fixtures/` when strictly needed.
- **Validation commands:**
  - `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
  - `./tests/run.sh tests/test_subtitle_mapping.sh tests/test_phase4_mapping.sh`
  - `bash scripts/check-fast.sh`
  - `bash scripts/check-changed.sh HEAD~1`
- **Completion criteria:** C01..C04 pass with explicit evidence in status/checkpoint; any remaining C05..C07 gaps are clearly tracked as follow-up runtime tranches.
- **Risks / rollback:** regressions in existing subtitle policy; rollback via targeted revert of tie-break/mapping delta and re-run targeted suites.

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
