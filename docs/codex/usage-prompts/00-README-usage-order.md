# Codex Usage Prompt Pack v1.1 - Usage Order

When to use: Start here before running any prompt in this pack.
Run in: Codex Cloud and Codex Local app (routing guide)

## Purpose
This pack provides copy/paste prompts for the finalized milestone workflow in this repository.
Prompts are operational helpers only; they must reflect (not replace) the existing control plane.

## Source-of-truth order
1. code / tests / runtime behavior / schemas / config
2. docs/codex/*
3. README / architecture / release docs
4. docs/project-files/*

`docs/project-files/` is downstream export only, not primary source of truth.

## Core anti-loop rule
- Milestone gate is contract-scoped (PLAN contract + DOC_SYNC_MATRIX), not a full repo audit.
- Blocker-closure check is narrow.
- Full repo audit is recovery-only.

## Standard milestone flow
1. `01-next-milestone-planner.md` (Cloud)
2. `02-milestone-implementation.md` (Cloud)
3. `03-milestone-gate.md` (Cloud)
4. If blocked: `04-blocker-patch.md` (Cloud)
5. `05-blocker-closure-check.md` (Cloud)
6. `06-final-local-verification.md` (Local app, when local/toolchain-sensitive or final machine check is needed)
7. `07-commit-push-after-pass.md` (Local app)

## Recovery flow
- `08-full-repo-audit-recovery.md` (Cloud, recovery-only)

## Release flow
- `09-release-prep.md` (Cloud)

## Prompt quick descriptions
- `01`: planning-only; creates next milestone contract and implementation handoff prompt.
- `02`: executes exactly one milestone-sized change.
- `03`: applies contract-scoped milestone gate with blocking vs follow-up classification.
- `04`: patches only listed blockers.
- `05`: verifies blocker closure narrowly plus regression safety.
- `06`: performs final local verification for machine/toolchain-sensitive confidence.
- `07`: performs safe, milestone-aware commit/push after pass.
- `08`: runs recovery-only full repo audit and outputs scoped repair plan.
- `09`: runs release-facing truth check and release readiness decision.

## Minimal operator checklist before use
- Confirm active milestone state in `docs/codex/PLAN.md` and `docs/codex/STATUS.md`.
- Confirm validation order and gate rules in `AGENTS.md` and `docs/codex/DOC_SYNC_MATRIX.md`.
- Confirm execution routing in `docs/codex/RUNBOOK.md` and `docs/codex/CLOUD_ENV_CHECKLIST.md`.

## Related control-plane docs
- `AGENTS.md`
- `docs/codex/PLAN.md`
- `docs/codex/STATUS.md`
- `docs/codex/RUNBOOK.md`
- `docs/codex/REPO_OVERVIEW.md`
- `docs/codex/DOC_SYNC_MATRIX.md`
- `docs/codex/CLOUD_ENV_CHECKLIST.md`
- `docs/codex/automations/README.md`

```text
Operator instruction:
Use one prompt at a time. Preserve the canonical sequence:
inspect -> plan -> implement one milestone -> validate (narrow first, then check-fast, check-changed if relevant, check-full if justified) -> sync required docs -> milestone gate -> blocker patch/closure if needed -> final local verification when needed -> commit/push.
Do not treat docs/project-files/ as source of truth.
```
