# Documentation Sync Matrix

Use this matrix to decide which documentation updates are required for milestone gate pass vs follow-up hygiene.

“Milestone completion is determined by the milestone contract plus the blocking rules in docs/codex/DOC_SYNC_MATRIX.md. Non-blocking documentation hygiene items should be recorded as follow-ups and must not automatically block advancement.”

“docs/project-files/ exists to generate concise files for upload into this repository’s ChatGPT Project. It is a downstream sync surface, not the primary source of truth for Codex. Code, tests, config, and docs/codex/* govern milestone decisions.”

| Change type | Update STATUS.md | Update RUNBOOK.md | Update PLAN.md | Update README.md | Update docs/project-files/* | Blocking for milestone completion? | Notes |
|---|---|---|---|---|---|---|---|
| runtime behavior change | Required (record validation evidence + milestone outcome) | If operator execution/gates changed | If milestone scope/criteria changed | If user-facing behavior/usage contract changed | If product/workflow summary changed materially | Yes (STATUS + any other required control-plane docs) | Validate changed behavior before gate. |
| safety/invariant change | Required | Required when safety process/guardrails changed | Required when milestone contract/safety criteria changed | Recommended when user-visible safety expectations changed | Required when safety boundary changed materially | Yes | Treat as high-risk; include explicit risk note in STATUS/checkpoint. |
| validation workflow change | Required | Required | If milestone validation contract changed | Optional (if contributor-facing quickstart validation changes) | Recommended when operator expectations changed materially | Yes | Keep validation order aligned with AGENTS.md. |
| operator workflow change | Required | Required | If milestone sequencing/criteria changed | Optional | Required when handoff process changed materially | Yes | Must preserve implement -> validate -> sync docs -> gate -> checkpoint -> commit/push sequence. |
| architecture/module-boundary change | Required | If operational handling changed | Required | Optional unless user-facing expectations changed | Required when architecture summary/handoff interpretation changes materially | Yes | Keep overview and plan terminology stable. |
| roadmap/milestone change | Required | Optional | Required | Optional | Optional (recommended for concise handoff sync) | Yes | PLAN is the milestone contract source. |
| config surface change | Required | If operator procedure for config changes | If milestone scope/criteria changed | Required for user-facing config/env changes | Required when project summary/invariants change materially | Yes | Include deterministic defaults and safety impacts. |
| report/schema/artifact change | Required when milestone outputs/evidence format changed | If runbook references artifact handling | If milestone contract deliverable changed | If release/user-facing artifact contract changed | Optional unless handoff/export expectations changed materially | Usually Yes when contract or gate evidence changes; otherwise No | Classify based on whether milestone contract/gate consumes the artifact. |
| project-files-only cleanup | Optional (note as follow-up if useful) | No | No | No | Yes | No | Explicitly non-blocking hygiene unless coupled to a blocking control-plane change. |
| release-facing behavior change | Required | If release operator workflow changed | If milestone contract for release changed | Required | Required when release summary/process changed materially | Yes | Ensure release docs and checks remain consistent. |

## Deterministic gate rule
- A milestone passes when its PLAN contract is satisfied and all blocking cells above are complete.
- Non-blocking cells must be tracked as follow-ups in `docs/codex/STATUS.md` (or checkpoint notes) and must not auto-fail the milestone gate.
