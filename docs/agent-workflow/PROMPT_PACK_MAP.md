# Prompt Pack Map

Maps each prompt in `docs/codex/usage-prompts/` to its workflow step, agent type, and purpose.

Prompt pack canonical location: `docs/codex/usage-prompts/`
Prompt pack version: see `docs/codex/WORKFLOW_VERSION.md`

## Index

| Filename | Workflow step | Agent type | Purpose |
|----------|--------------|-----------|---------|
| `0000-README.md` | — | Any | Index, routing rules, and discovery order. Read first. |
| `000-repo-audit.md` | Recovery only | Remote | Full repo audit when state is unclear or drifted. Not a normal gate. |
| `00-repo-starter.md` | Day-0 init | Remote | Initialize a new repo or repo without a control plane. Use once. |
| `01-next-milestone-planner.md` | Plan | Remote | Determine next milestone from repo state. Use after gate PASS + SAFE TO MOVE ON. |
| `02-milestone-implementation.md` | Implement | Remote / Local | Execute one milestone-sized change. |
| `03-milestone-gate.md` | Gate | Remote | Review milestone completion against PLAN contract + DOC_SYNC_MATRIX. |
| `04-blocker-patch.md` | Fix | Remote | Fix blocking issues only. Narrow scope. |
| `05-blocker-closure-check.md` | Verify fix | Remote | Verify blockers are resolved. Not a full re-review. |
| `06A-local-handoff+verification.md` | Local handoff | Local | Handoff to local environment + run final verification. |
| `06B-local-verification.md` | Local verify | Local | Final verification only (if already handed off). |
| `07A-commit-push.md` | Commit/push | Local | Commit and push after gate PASS. |
| `07B-squash-merge.md` | Merge | Local | Squash-merge topic branch to main. |
| `08-release-prep.md` | Release review | Remote | Review release readiness before tagging. |
| `09-tag&release.md` | Tag/release | Local | Create git tag and GitHub release. |

## Standard flow mapping

```
01 (plan) → 02 (implement) → 03 (gate)
  → if FAIL: 04 (fix) → 05 (verify fix) → 03
  → if PASS: 06A or 06B (local verify if needed)
  → 07A (commit/push)
  → 07B (merge if topic branch)
```

## Release flow mapping

```
08 (release prep review) → 07A if needed → 07B → 09 (tag/release)
```

## Recovery flow mapping

```
000 (repo audit) → 01 (plan)
```

## Anti-loop constraints (from prompt pack)

- `000` (repo audit) is recovery-only. Do not use as a normal milestone gate.
- `05` (blocker-closure) is narrow. Do not use as a broad repo re-review.
- `08` (release-prep) is review-only. Do not use as a general cleanup pass.

## Agent type legend

- **Remote** — suitable for Codex Cloud, Claude API, Aider with API
- **Local** — requires local environment with git, ffmpeg, bash toolchain, and push credentials
- **Any** — informational / read-only; any agent can use it
