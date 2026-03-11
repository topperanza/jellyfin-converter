# 09 Release Prep

When to use: Use before release or release-candidate handoff for release-facing truth checks.
Run in: Codex Cloud

```text
Task: run release-prep truth check against current repository state.

Check:
- release-facing docs and behavior consistency
- validation readiness and evidence quality
- milestone/status/checkpoint handoff clarity
- DOC_SYNC_MATRIX blocking vs non-blocking handling
- safety and deterministic behavior statements still accurate

Classification:
- release blockers
- non-blocking follow-ups

Decision must be exactly one of:
- READY FOR RELEASE
- FIX RELEASE BLOCKERS FIRST

Rules:
- Keep this review operational and evidence-based.
- Do not change runtime behavior in this review.
- Convert discovered gaps into scoped milestones.

Output required:
- decision
- release blockers
- non-blocking follow-ups
- recommended next prompt
```
