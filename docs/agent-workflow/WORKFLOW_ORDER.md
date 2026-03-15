# Workflow Order

Canonical milestone flow, validation order, and routing rules for all agents.

Source: extracted from `docs/codex/usage-prompts/0000-README.md`, `docs/codex/RUNBOOK.md`, and `AGENTS.md`.

## Standard milestone flow

```
01 → next-milestone-planner
02 → milestone-implementation
03 → milestone-gate
```

If gate fails (blockers found):
```
04 → blocker-patch
05 → blocker-closure-check
→ return to 03
```

If local verification is needed before commit:
```
06A → local-handoff+verification   (handoff + verification together)
06B → local-verification           (verification only, if already handed off)
```

Then finalize:
```
07A → commit-push
07B → squash-merge   (if on a topic branch)
```

## Release flow

Use only after all milestone work is complete and committed.

```
08 → release-prep review
07A → commit-push (only if release-ready changes still need pushing)
07B → squash-merge
09 → tag & release
```

Release order is always: review → commit/push if needed → tag + release.

## Recovery flow

If repository state is unclear or drifted:
```
000 → repo-audit (recovery only)
→ return to standard flow
```

## Day-0 / initialization

For a new repo with no control plane:
```
00 → repo-starter
→ return to standard flow
```

## Validation order

Always run in this sequence unless the milestone contract explicitly overrides:

1. **Narrow milestone-specific validation first**
   - Example: `./tests/run.sh tests/suite_selection.sh tests/suite_ffmpeg.sh`
2. **`bash scripts/check-fast.sh`** — syntax + parser tests
3. **`bash scripts/check-changed.sh HEAD~1`** — only if present and the changed scope warrants it
4. **`bash scripts/check-full.sh`** — only if justified by changed runtime breadth or risk

Evidence logging (required for STATUS.md and checkpoints):
- Command run + pass/fail/skip reason
- Matrix-case mapping and proof fragments where applicable
- Environment limitations and residual risks

## Remote vs local routing

Use a **remote-capable agent** (Codex Cloud, Claude API, Aider with API) for:
- planning
- milestone implementation
- milestone gate review
- blocker-closure checks
- release-prep review
- repo audits
- control-plane doc work
- prompt-pack maintenance

Use a **local agent** (Codex Local app, local Claude Code, local Aider) for:
- environment-sensitive fixes
- local verification (06A/06B)
- setup/maintenance/validation script work
- hardware/toolchain/platform-sensitive verification
- commit/push (07A)
- tag/release (09)

## Anti-loop rules

- Do NOT use the full repo audit (`000`) as a normal milestone gate.
- Do NOT use blocker-closure check (`05`) as a broad repo re-review.
- Do NOT use release-prep (`08`) as a general cleanup prompt.
- Do NOT repeat the same validation command in a loop on failure without diagnosing the root cause first.

Keep scope tight.

## Milestone execution loop (detailed)

1. Identify milestone contract in `docs/codex/PLAN.md`.
2. Implement one milestone-sized change.
3. Run validation in order above.
4. Update required docs per `docs/codex/DOC_SYNC_MATRIX.md`.
5. Apply milestone gate: PLAN contract + all blocking DOC_SYNC_MATRIX rows satisfied → PASS.
6. Record pass/follow-ups in `docs/codex/STATUS.md`.
7. If blocked, fix blockers only and run targeted blocker-closure check.
8. Write/update checkpoint: `.codex/checkpoints/MILESTONE-<n>.md`.
9. Commit/push.

Milestone completion is determined by the milestone contract plus the blocking rules in `docs/codex/DOC_SYNC_MATRIX.md`. Non-blocking documentation hygiene items must be recorded as follow-ups and must not automatically block advancement.
