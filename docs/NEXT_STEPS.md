# Product Milestones (Post-Realignment)

This roadmap reflects the narrowed product direction: finish and clarify the current local safety-first converter, not broad platform expansion.

## M0 — Scope + release narrative alignment (current)
- Align README/scope/architecture/milestone/release wording to one product story.
- Make v1/v1.1/v2 boundaries explicit.
- Keep user-facing product docs separate from contributor control-plane docs.

## M1 — High-risk runtime validation contract (next)
- Define and ratify representative, risk-focused validation coverage for:
  - stream-selection determinism
  - subtitle/audio mapping behavior
  - ffmpeg command/mapping correctness
  - verification-before-delete safety boundaries
- Focus on confidence for risky runtime iteration; no broad feature expansion.

## M2 — Thin local GUI over canonical runtime
- Keep CLI as canonical source-of-truth execution path.
- Ensure GUI remains operator-oriented and thin.
- Avoid consumer GUI framing or scope creep.

## M3 — Packaging + cross-platform operator readiness
- Close remaining installer/distribution friction for operator use.
- Keep release artifacts and operator docs aligned with CLI contract and safety defaults.

## M4 — v1 release gate
- Confirm v1 production-usable bar:
  - safe defaults and destructive-action gates
  - deterministic and repeat-run-safe operation
  - representative edge-case confidence for mixed-language mapping behavior
  - operator docs and cross-platform packaging aligned for practical use

## Version framing
- **v1:** must-have local CLI + thin local GUI + deterministic conversion + safety gates + validation confidence + packaging/readiness.
- **v1.1:** polish (GUI ergonomics, packaging ergonomics, non-blocking docs, broader-but-non-blocking sample coverage).
- **v2+:** web frontend, multi-user/auth, cloud/hosted execution, broader integrations, and non-MKV-first expansion as core commitments.
