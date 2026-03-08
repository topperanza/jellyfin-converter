# Codex Runbook

Operational commands for long-running Codex tasks in this repository.

## 1) Start a fresh Codex session
```bash
bash scripts/codex/setup.sh
```

If container state is already warm/resumed:
```bash
bash scripts/codex/maintenance.sh
```

## 2) Read before editing
1. `AGENTS.md`
2. `docs/codex/PLAN.md`
3. `docs/codex/STATUS.md`
4. Most recent `.codex/checkpoints/MILESTONE-<n>.md`

## 3) Milestone execution loop
1. Confirm active milestone scope from `docs/codex/PLAN.md`.
2. Make narrow changes only inside that scope.
3. Run milestone validation commands.
4. Update `docs/codex/STATUS.md`.
5. Write/update `.codex/checkpoints/MILESTONE-<n>.md`.

## 4) Validation command set
Fast validation:
```bash
bash scripts/check-fast.sh
```

Changed-file validation (recommended explicit base ref):
```bash
bash scripts/check-changed.sh HEAD~1
```

Full validation before milestone/final handoff:
```bash
bash scripts/check-full.sh
```

## 5) Checkpoint template
Create `.codex/checkpoints/MILESTONE-<n>.md` with:
- Goal and completion criteria
- Files changed
- Commands run
- Results (pass/fail/skip + reason)
- Risks and next step

## 6) Handoff checklist
- Working tree clean except intended changes.
- `docs/codex/STATUS.md` reflects latest command evidence.
- Checkpoint file is present for the completed milestone.
- Final validation command output is captured in task summary.
