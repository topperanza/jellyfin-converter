# Handoff

## Status
No active task.

## Branch
main

## Scaffold status
v1.2.0 workflow baseline present.

## Files added/updated for the v1.2.0 workflow baseline
- docs/agent-workflow/ADAPTER_CONTRACT.md — added (new)
- docs/agent-workflow/CLOUD_TO_LOCAL_HANDOFF.md — added (new)
- docs/agent-workflow/COMMIT_RELEASE.md — added (new)
- docs/agent-workflow/VALIDATION_ORDER.md — added (new)
- docs/agent-workflow/README.md — updated (contents table + task-state refs)
- docs/agent-workflow/TRIPLE_AGENT_ALIGNMENT.md — title naming drift fixed
- AGENTS.md — trimmed to thin adapter; repo-specific invariants preserved
- CLAUDE.md — trimmed to thin adapter; Purpose/Entry points/Repo-specific notes preserved
- .aider.conf.yml — added dirty-commits: false and test-cmd
- HANDOFF.md — created (this file)
- PROJECT_CONTEXT.md — created

## Required validation
1. `bash scripts/codex/check-workflow-conformance.sh`
2. `bash scripts/check-fast.sh`

## Known uncertainties
None.

## Ready for local verification
No additional local verification queued for this state-doc cleanup.
