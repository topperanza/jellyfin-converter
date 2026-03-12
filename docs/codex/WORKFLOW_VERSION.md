# Codex Workflow Version

- Current workflow version: `v1.2.2`
- Prompt pack path (canonical `PROMPTS_DIR`): `docs/codex/usage-prompts`
- Last updated: 2026-03-12 (milestone-6 follow-up)

## Scope
This file versions the repository Codex control-plane workflow surfaces and keeps prompt-pack routing explicit.

## Version history
- `v1.2.2` (2026-03-12)
  - Added README-level canonical prompt-pack path reference for faster control-plane discoverability.
  - Aligned downstream `docs/project-files/validation-summary.md` ordering with milestone-specific-first validation policy.
  - Extended `scripts/codex/check-workflow-conformance.sh` with legacy prompt-path reference checks for active control-plane docs.
- `v1.2.1` (2026-03-12)
  - Added explicit CI hard gate for `bash scripts/codex/check-workflow-conformance.sh`.
  - Tightened conformance checks with canonical prompt-pack filename/schema set validation.
  - Annotated legacy prompt-pack filename references in historical checkpoint records.
- `v1.2.0` (2026-03-12)
  - Added executable workflow conformance script: `scripts/codex/check-workflow-conformance.sh`.
  - Normalized workflow references to the canonical prompt pack location: `docs/codex/usage-prompts`.
  - Confirmed release flow sequence remains: release-prep review -> final commit/push -> tag + release.
- `v1.1.0` (existing prompt-pack baseline)
  - Canonical usage prompt pack established under `docs/codex/usage-prompts`.
