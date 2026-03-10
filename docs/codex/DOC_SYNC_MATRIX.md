# Documentation Sync Matrix

This matrix defines what blocks milestone advancement vs what is follow-up hygiene.

## Blocking updates (must be done before milestone gate passes)
| Trigger | Required updates |
|---|---|
| Milestone scope/contract changes | `docs/codex/PLAN.md` |
| Validation evidence changes for active milestone | `docs/codex/STATUS.md` |
| Operational workflow or gate behavior changes | `docs/codex/RUNBOOK.md` and/or `AGENTS.md` |
| Repo control-plane source-of-truth changes | `docs/codex/REPO_OVERVIEW.md` |

## Non-blocking updates (record follow-up; do not auto-block milestone)
| Trigger | Typical files |
|---|---|
| Summary-layer wording improvements | `docs/project-files/*.md` |
| Copyediting/format cleanup without workflow impact | Any docs outside active milestone contract |
| Additional context that does not change behavior/contracts/gates | `docs/project-files/*.md`, optional runbook notes |

## Milestone gate rule
Milestone completion is determined by the milestone contract plus the blocking rules above. Non-blocking documentation hygiene items should be recorded as follow-ups and must not automatically block advancement.
