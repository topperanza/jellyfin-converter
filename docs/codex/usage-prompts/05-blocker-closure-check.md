# 05 Blocker Closure Check

When to use: Use immediately after Prompt 04 to verify blocker closure.
Run in: Codex Cloud

```text
Task: verify only known blockers are closed, plus regression safety on touched scope.

Checks:
- confirm each known blocker is resolved
- confirm no new blocker in touched paths
- run narrow regression-safety checks for touched scope
- run bash scripts/check-fast.sh
- confirm STATUS/checkpoint evidence updated

Rules:
- Keep this check narrow.
- No full milestone rediscovery.
- No full repo audit.

Output required:
- closure result: CLEARED or NOT CLEARED
- evidence commands and results
- remaining blockers (if any)
- next required prompt (03 retry or 06)
```
