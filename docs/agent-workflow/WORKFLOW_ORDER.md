# Workflow Order

This file encodes the workflow sequences defined by `docs/codex/usage-prompts/`.
The prompt pack is the authoritative source; this file is a shared summary for all agents.

## Standard milestone flow

```
01-next-milestone-planner
02-milestone-implementation
03-milestone-gate
```

If blocked after the gate:
```
04-blocker-patch
05-blocker-closure-check
```

If local verification is needed before commit:
```
06A-local-handoff+verification   ← use when bringing cloud work into local repo
06B-local-verification           ← use when work is already local
```

Then commit and merge:
```
07A-commit-push
07B-squash-merge                 ← only if not already on main
```

## Release flow

Use only after milestone work is committed and state is ready.

```
08-release-prep
07A-commit-push    ← only if release-ready changes still need commit/push
07B-squash-merge
09-tag&release
```

Release order is always: release-prep → final commit/push (if needed) → tag + release.

## Recovery flow

If repository state is unclear, drifted, or the control plane is untrustworthy:

```
000-repo-audit
```

Then return to the standard flow.

## Day-0 / initialization flow

For a new repo or one without a proper control plane:

```
00-repo-starter
```

## Validation order (canonical — applies to every milestone)

Run in this order; do not skip ahead:

1. Narrow milestone-specific validation first
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` — only if present and relevant
4. `bash scripts/check-full.sh` — only if justified by scope or risk

## Agent routing

Use a **cloud/remote agent** (Codex Cloud) for:
- next milestone planning
- normal milestone implementation
- milestone gate
- blocker-closure checks
- repo-wide audits
- docs/control-plane work
- release prep review

Use a **local agent** (Codex Local, Claude Code) for:
- environment-sensitive fixes
- setup / maintenance / validation script work
- hardware/toolchain/platform-sensitive verification
- final local verification
- commit/push
- tag/release

## Anti-loop rules

Do not use:
- full repo audit as a normal milestone gate
- blocker-closure as a broad repo re-review
- release-prep as a general cleanup prompt

Keep scope tight to the current prompt's stated purpose.
