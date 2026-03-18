# 0000-README.md

# Codex Prompt Pack v1.3.0 — Usage Order

This folder contains the Codex-facing prompt pack for this repository.

The pack is designed to remain usable in a triple-agent workflow:
- durable workflow truth must live in the repository
- `docs/agent-workflow/*` is canonical if present
- `docs/codex/*` is the Codex-facing control-plane layer
- `AGENTS.md` and `CLAUDE.md` are adapters, not the primary source of truth
- `docs/project-files/*` is downstream/export-only unless the canonical workflow docs explicitly require it

## Control-plane discovery order

Use this order when reading workflow truth:
1. code / tests / runtime behavior / schemas / config
2. `docs/agent-workflow/*` if present
3. `docs/codex/*`
4. README / architecture / release docs
5. `docs/project-files/*`

If `docs/agent-workflow/*` does not exist yet, treat `docs/codex/*` as the current control plane.

## Core rules

- Milestone gate is contract-scoped.
- Blocker-closure check is narrow.
- Full repo audit is recovery-only.
- Canonical validation order is:
  1. milestone-specific validation
  2. `bash scripts/check-fast.sh`
  3. `bash scripts/check-changed.sh` if present and relevant
  4. `bash scripts/check-full.sh` only if justified
- Automations are app-managed, not repo-managed.
- Do not rely on agent session memory as a source of truth.
- Keep adapter files thin and repo-local truth explicit.

## Standard milestone flow

1. `01-next-milestone-planner.md`
2. `02-milestone-implementation.md`
3. `03-milestone-gate.md`

If blocked:
4. `04-blocker-patch.md`
5. `05-blocker-closure-check.md`

If local verification is needed:
6. `06A-local-handoff+verification.md` or `06B-local-verification.md`

Then:
7. `07A-commit-push.md`
8. `07B-squash-merge.md`

## Release flow

Use only after milestone work is complete and committed state is ready.

1. `08-release-prep.md`
2. `07A-commit-push.md` only if release-ready changes already exist locally and still need commit/push
3. `07B-squash-merge.md`
4. `09-tag&release.md`

Release order is always:
- release-prep review
- final commit/push only if needed
- tag + release

## Recovery flow

If repository state is unclear, drifted, or the control plane is untrustworthy:

1. `000-repo-audit.md`

Then return to the standard flow.

## Day-0 / initialization flow

For a new repo or a repo that does not yet have a proper control plane:

1. `00-repo-starter.md`

## Remote vs local guidance

Use a remote-capable agent for:
- planning
- milestone implementation
- milestone gate
- blocker-closure checks
- release-prep review
- repo audits
- control-plane doc work
- prompt-pack maintenance

Use a local-capable agent for:
- environment-sensitive fixes
- local verification
- setup/maintenance validation
- commit/push
- tag/release

## Anti-loop rule

Do not use:
- full repo audit as a normal milestone gate
- blocker-closure as a broad repo re-review
- release-prep as a general cleanup prompt

Keep scope tight.

## Deferred for now

Cross-repository synchronization is intentionally not part of this baseline prompt pack.
Apply rollout and review flows one repository at a time.