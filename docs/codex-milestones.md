# Codex Milestone Workflow

Use this for long-running Codex tasks so work is resumable and reviewable.

## Paths
- Checkpoints: `.codex/checkpoints/`
- Status notes: `.codex/checkpoints/MILESTONE-<n>.md`

## Milestone pattern
- Milestone 0: inspect current behavior + write a plan.
- Milestone 1+: one coherent implementation step per milestone.
- End each milestone with:
  - files changed
  - commands run
  - results
  - known risks / next step

## Checkpoint template
Create/update `.codex/checkpoints/MILESTONE-<n>.md` with:

```md
# Milestone <n>: <title>
- Date:
- Goal:
- Completion criteria:

## Files changed
- `path/to/file`

## Commands run
- `command`

## Results
- pass/fail summary

## Risks / next step
- ...
```

## Validation per milestone
Run the stable validation entrypoints first, then full tests before handoff:

```bash
bash scripts/check-fast.sh
bash scripts/check-changed.sh
bash scripts/check-full.sh
```

Keep diffs minimal and do not weaken dry-run-first safety defaults.
