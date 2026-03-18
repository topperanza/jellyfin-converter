# Non-Negotiables

Hard rules that apply to every agent and every workflow step.
Every rule below is evidenced by at least one committed repository file.

Do not loosen these rules without direct repo evidence that they are wrong.
Do not invent new rules here; add them only when evidenced.

---

## 1. No secrets in tracked files

Never add or expose secrets, API keys, tokens, or credentials in any tracked file,
log, fixture, prompt, checkpoint, or example.
If an env template is needed, use `.env.example` with placeholders only.

_Evidence: `AGENTS.md`, `docs/codex/CLOUD_ENV_CHECKLIST.md`, `docs/codex/usage-prompts/07A-commit-push.md`_

---

## 2. Keep diffs narrow and task-scoped

Do not perform unrelated refactors, formatting churn, or opportunistic cleanup
outside the stated task scope.

_Evidence: `AGENTS.md`, `docs/codex/usage-prompts/02-milestone-implementation.md`_

---

## 3. Originals untouched by default

Media source files remain untouched by default.
Destructive flows must be explicit, gated, and user-confirmed.

_Evidence: `docs/codex/REPO_OVERVIEW.md`, `AGENTS.md`_

---

## 4. Prefer deterministic, reproducible behavior

Prefer explicit, deterministic codec/container/stream rules over implicit ffmpeg behavior or convenience shortcuts.

_Evidence: `AGENTS.md`, `docs/codex/REPO_OVERVIEW.md`_

---

## 5. Canonical validation order is mandatory

Always run in this order:
1. Narrow milestone-specific validation first
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` (only when present and relevant)
4. `bash scripts/check-full.sh` (only when justified by scope or risk)

Do not skip ahead. Do not run check-full.sh for doc-only changes.

_Evidence: `AGENTS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/PLAN.md`, `docs/codex/usage-prompts/0000-README.md`_

---

## 6. No force-push; no history rewriting

Do not force-push. Do not rewrite or amend published commits without explicit user instruction.

_Evidence: `docs/codex/usage-prompts/07A-commit-push.md`_

---

## 7. docs/project-files/ is downstream export only

`docs/project-files/` exists to generate concise files for ChatGPT Project uploads.
It is not a primary source of truth for milestone decisions.
Code, tests, config, and `docs/codex/*` govern milestone decisions.

_Evidence: `AGENTS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/DOC_SYNC_MATRIX.md`,
`docs/codex/REPO_OVERVIEW.md`, `docs/codex/usage-prompts/0000-README.md`_

---

## 8. Milestone gate is contract-scoped, not a full audit

A milestone gate evaluates only the current milestone contract plus the blocking rules
in `docs/codex/DOC_SYNC_MATRIX.md`. It is not a full repo truth audit.

_Evidence: `docs/codex/DOC_SYNC_MATRIX.md`, `docs/codex/usage-prompts/03-milestone-gate.md`,
`docs/codex/usage-prompts/0000-README.md`_

---

## 9. Non-blocking hygiene must not auto-fail a milestone gate

Non-blocking documentation hygiene items must be recorded as follow-ups in
`docs/codex/STATUS.md` or checkpoint notes. They must not block milestone advancement.

_Evidence: `docs/codex/DOC_SYNC_MATRIX.md`, `docs/codex/RUNBOOK.md`, `AGENTS.md`, `docs/codex/PLAN.md`_

---

## 10. No case-only path duplicates; repo directories use lowercase names

Do not introduce case-only duplicates of generic repo directories.

_Evidence: `AGENTS.md`_

---

## 11. Ask only when blocked; otherwise proceed with one short assumption

Do not stall for clarification. Make one short, explicit assumption and proceed.
State the assumption in the output.

_Evidence: `AGENTS.md`_

---

## 12. AGENTS.md and CLAUDE.md are adapters, not primary sources of truth

Read `docs/agent-workflow/*` first, then `docs/codex/*`.
Adapter files defer to those canonical sources.

_Evidence: `docs/codex/usage-prompts/0000-README.md`, all milestone prompts_

---

## 13. docs/agent-workflow/* takes precedence over docs/codex/* for workflow decisions

When a conflict exists between the shared workflow layer and the Codex control-plane layer,
the shared workflow layer wins unless the Codex-specific rule is intentionally narrower.

_Evidence: `docs/codex/usage-prompts/0000-README.md`, all milestone/gate/commit prompts_

---

## 14. Do not modify local Claude control surfaces directly

Do not modify `.claude/settings.json`, `.claude/settings.local.json`, `.git/info/exclude`,
or create `.claude/commands/` — a PreToolUse hook blocks tool-based writes to these paths.
Edit manually if intentional.

_Evidence: `docs/agent-workflow/NON_NEGOTIABLES.md` (ai-dev-template v1.3.2 baseline)_
