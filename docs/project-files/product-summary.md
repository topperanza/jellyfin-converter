# Product Summary

## Product sentence
`jellyfin-converter` is a safety-first local conversion tool for a single operator, centered on deterministic stream-selection and explicit destructive-action gates, with a CLI as the canonical execution path and a thin local GUI for operator convenience.

## Main operator outcome
- Safely convert local media into Jellyfin-friendly MKV outputs.
- Keep destructive cleanup explicitly gated and optional.
- Get predictable repeat-run behavior via deterministic policy + processed tracking.

## v1 in-scope
- Local CLI workflow (canonical path).
- Thin local GUI workflow (operator convenience layer).
- Scan/probe/selection/mapping pipeline.
- Subtitle/audio policy and MKV-first output generation.
- Output verification before optional destructive cleanup.
- Repeat-run safety and recursive-churn guardrails.
- Packaging/distribution and operator docs suitable for cross-platform use.

## v1 out-of-scope
- Web frontend.
- Multi-user auth/roles.
- Cloud/hosted execution.
- Media-library management beyond conversion.
- Broad integration platform.

## Release framing
- v1 = must-have safety + deterministic conversion + CLI-canonical operation + thin local GUI + operator-ready packaging/docs.
- v1.1 = polish (GUI ergonomics, packaging ergonomics, non-blocking doc polish, broader sample coverage).
- v2+ = broader platform directions (web, multi-user, cloud, integrations, non-MKV-first as core promise).
