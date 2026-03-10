# Codex Runbook

Operational commands for long-running Codex tasks in this repository.

Milestone completion is determined by the milestone contract plus the blocking rules in docs/codex/DOC_SYNC_MATRIX.md. Non-blocking documentation hygiene items should be recorded as follow-ups and must not automatically block advancement.

docs/project-files/ exists to generate concise files for upload into this repository’s ChatGPT Project. It is a downstream sync surface, not the primary source of truth for Codex. Code, tests, config, and docs/codex/* govern milestone decisions.

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
4. `docs/codex/REPO_OVERVIEW.md`
5. `docs/codex/DOC_SYNC_MATRIX.md`
6. Most recent `.codex/checkpoints/MILESTONE-<n>.md`

## 3) Milestone execution loop
1. Confirm active milestone scope from `docs/codex/PLAN.md` (implement).
2. Run milestone validation commands (validate).
3. Update required docs per `docs/codex/DOC_SYNC_MATRIX.md`.
4. Apply milestone gate using milestone contract + DOC_SYNC_MATRIX blocking rules; record pass/follow-ups in `docs/codex/STATUS.md`.
5. Write/update `.codex/checkpoints/MILESTONE-<n>.md` (checkpoint).
6. Commit/push.

## 3a) Milestone ID policy
- Active implementation work must use numbered IDs from `docs/codex/PLAN.md` (`MILESTONE-<n>` in plan order).
- Exceptional documentation-only closures may use non-numbered IDs (for example `MILESTONE-docs-project-files`) but must be listed in `docs/codex/STATUS.md` as additional completed closures, not as the current active milestone.

## 4) Validation command set
Fast validation:
```bash
bash scripts/check-fast.sh
```

Milestone-targeted validation:
```bash
./tests/run.sh <suite-or-pattern>...
```

Changed-file validation (recommended explicit base ref):
```bash
bash scripts/check-changed.sh HEAD~1
```

Full validation before milestone/final handoff:
```bash
bash scripts/check-full.sh
```

Use the active milestone command block in `docs/codex/PLAN.md` to select exact targeted suites.
Example for subtitle ranking milestones:
```bash
./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh
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
- Required docs are updated per `docs/codex/DOC_SYNC_MATRIX.md`; non-blocking items are tracked as follow-ups.
- Checkpoint file is present for the completed milestone.
- Final validation command output is captured in task summary.
