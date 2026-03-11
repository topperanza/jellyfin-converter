# 03 Milestone Gate

When to use: Use after milestone implementation and validation evidence are recorded.
Run in: Codex Cloud

```text
Task: run contract-scoped milestone gate (not a full repo audit).

Gate checks:
1) PLAN completion criteria satisfied?
2) DOC_SYNC_MATRIX blocking updates complete?
3) canonical validation order evidence present?
4) STATUS and checkpoint updated with evidence?

Classification:
- unresolved item must be labeled exactly one of:
  - BLOCKING
  - NON-BLOCKING FOLLOW-UP

Decision must be exactly one of:
- SAFE TO MOVE ON
- FIX BLOCKERS FIRST
- DO NOT ADVANCE YET

Rules:
- Milestone completion = PLAN contract + DOC_SYNC_MATRIX blocking rules.
- Non-blocking documentation hygiene must not auto-block advancement.
- docs/project-files remains downstream export only.

Output required:
- decision
- blocking items
- non-blocking follow-ups
- next required prompt (04/05 or 06)
```
