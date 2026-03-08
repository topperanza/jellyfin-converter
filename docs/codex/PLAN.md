# Codex Long-Run Plan

## Milestone pattern
1. Plan and scope the next milestone.
2. Implement one coherent milestone.
3. Validate in preferred order.
4. Update `docs/codex/STATUS.md`.
5. Write/update `.codex/checkpoints/MILESTONE-<n>.md`.

## Completion criteria
- Behavior matches milestone goal.
- Safety invariants remain intact (dry-run-first, originals untouched unless delete flags are explicit, deterministic outputs).
- Required validation passes or has explicit environment-bound skips.
- Status + checkpoint are updated.

## Checkpoint format
Use `.codex/checkpoints/MILESTONE-<n>.md` with:
- milestone goal and completion criteria
- files changed
- commands run
- result summary
- known risks and next step

## Preferred validation after each milestone
```bash
bash scripts/check-fast.sh
bash scripts/check-changed.sh
bash scripts/check-full.sh
```

## Final handoff validation
```bash
bash scripts/check-fast.sh
bash scripts/check-changed.sh
bash scripts/check-full.sh
./tests/run.sh
```
