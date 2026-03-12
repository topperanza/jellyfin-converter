# Codex Workflow Version

- Current workflow version: `v1.2.0`
- Prompt pack path (canonical `PROMPTS_DIR`): `docs/codex/usage-prompts`
- Last updated: 2026-03-12

## Scope
This file versions the repository Codex control-plane workflow surfaces and keeps prompt-pack routing explicit.

## Version history
- `v1.2.0` (2026-03-12)
  - Added executable workflow conformance script: `scripts/codex/check-workflow-conformance.sh`.
  - Normalized workflow references to the canonical prompt pack location: `docs/codex/usage-prompts`.
  - Confirmed release flow sequence remains: release-prep review -> final commit/push -> tag + release.
- `v1.1.0` (existing prompt-pack baseline)
  - Canonical usage prompt pack established under `docs/codex/usage-prompts`.
