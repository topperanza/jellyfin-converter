# Workflow Invariants

## Product/runtime invariants
- The tool is local-first, safety-first, and scoped to a single operator in v1.
- CLI is the canonical execution path; any GUI is a thin local operator layer.
- Deterministic stream-selection/mapping is required for reproducible outputs.
- `DRY_RUN=1` default and delete-off default are mandatory safety defaults.
- Destructive actions require explicit confirmation and verification-before-cleanup.
- Processed tracking + output-path guardrails are required for repeat-run safety.

## Validation and release invariants
- High-risk runtime paths (stream-selection, subtitle/audio mapping, ffmpeg mapping) require representative matrix evidence, not ad-hoc confidence claims.
- Runtime-confidence matrix baseline is M1-C01..M1-C07 and must stay explicit in milestone status/checkpoint docs.
- Validation order remains milestone-specific checks first, then fast, then changed/full checks as justified.
- Runtime-confidence milestones must report command outcomes and matrix-case proof fragments (`-map`, `-disposition`, stable ordering).
- v1 release bar includes operator-ready packaging/distribution plus aligned README/scope/changelog narrative.

## Control-plane separation invariant
- Product docs explain operator-facing behavior/scope.
- `docs/codex/*` explains contributor process, planning, and milestone gates.
- `docs/project-files/*` stays concise and downstream to canonical docs/tests/config.
