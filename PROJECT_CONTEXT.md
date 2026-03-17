# Project Context

## Current Task
- Objective: propagate ai-dev-template v1.2.0 workflow baseline into jellyfin-converter
- Success criteria: all new workflow docs present, adapters thinned, naming drift fixed, check-fast passes
- Out of scope: product changes, source code edits, docs/codex/usage-prompts/* changes, push

## Current State
- Branch: main
- Scaffold status: v1.2.0 propagation in progress
- Baseline source: ~/github/ai-dev-template

## Preserved as-is
- docs/agent-workflow/NON_NEGOTIABLES.md — repo version is richer (13 rules vs 9); Rules 6, 12, 13 confirmed present
- docs/agent-workflow/WORKFLOW_ORDER.md — repo version is richer; no changes needed
- docs/agent-workflow/SOURCE_OF_TRUTH.md — repo version is richer; no changes needed
- docs/agent-workflow/PROMPT_PACK_MAP.md — repo-specific prompt index; no changes needed
- scripts/check-fast.sh — 100% repo-specific; never overwritten by template
- All source code, tests, scripts/codex/*, docs/codex/*, docs/project-files/*

## Verification
- conformance check: pending
- check-fast: pending

## Next Best Action
Run `bash scripts/codex/check-workflow-conformance.sh`, then `bash scripts/check-fast.sh`. Confirm both PASS, then commit.

## Blockers
None.
