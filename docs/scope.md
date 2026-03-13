# Scope & Version Boundaries

## Problem statement
Operators with local media libraries need a predictable and safe way to convert files into Jellyfin-friendly outputs without accidental data loss or conversion churn.

## Product objective
Deliver a narrow, reliable, safety-first local conversion tool that produces Jellyfin-friendly MKV outputs with deterministic stream-selection and explicit destructive-action gates.

## Primary v1 user
- Single operator (Matteo / local maintainer).
- Technical operator assumptions are valid for v1.

## Explicitly not the v1 user
- Non-technical end users.
- Users expecting a polished general-purpose consumer GUI.
- Teams needing multi-user auth/roles.
- Hosted/cloud-service customers.

## v1 must-have scope
- Canonical local CLI workflow.
- Thin local GUI for operator convenience over the same canonical core flow.
- Scan/probe workflow.
- Deterministic stream-selection and mapping.
- Subtitle/audio mapping policy.
- MKV-first output generation.
- Output verification before destructive cleanup.
- Safe optional cleanup/delete paths with explicit destructive-action gates.
- Processed tracking and repeat-run safety.
- Guardrails against recursive output churn.
- Clear operator docs.
- Packaging/distribution quality sufficient for cross-platform operator use.
- Validation expectations strong enough for high-risk runtime changes.

## v1.1 (nice-to-have)
- Broader GUI polish beyond operator-only needs.
- Additional packaging/install ergonomics.
- Non-blocking documentation polish.
- Broader sample-library coverage beyond the agreed representative edge-case matrix.

## v2+ (out of v1 scope)
- Web frontend.
- Multi-user features/auth.
- Cloud/hosted execution.
- Media-library management beyond conversion.
- Broad integrations.
- Non-MKV-first expansion as a core promise.

## Core assumptions
- Local-first operation.
- Deterministic and reproducible behavior for identical inputs/config.
- Safety defaults remain on (`dry-run` default, delete off by default).
- Typical movie files, typical TV episode files, and mixed-language libraries are non-negotiable v1 media cases.
- Edge-case validation is representative and risk-focused, not exhaustive for every public case.

## Canonical key user flow
1. Scan input media.
2. Probe streams.
3. Apply deterministic stream-selection/mapping policy.
4. Write Jellyfin-friendly MKV output.
5. Verify result.
6. Optionally allow destructive cleanup behind explicit confirmation.

## v1 success criteria
- Real local library use is safe by default.
- Outputs are predictable and reproducible.
- Repeat runs do not create avoidable churn.
- High-risk stream-selection/subtitle/ffmpeg mapping behavior has strong validation coverage.
- Packaging/distribution and operator docs are good enough for cross-platform use.
- README, CHANGELOG, and scope/version narratives remain aligned.
