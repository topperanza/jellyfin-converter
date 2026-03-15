# Non-Negotiables

Hard rules for all agents working in this repository.

All rules below are evidenced by committed repo files. Each rule includes its source.

---

## Safety and destructive-action controls

**Originals remain untouched by default.**
Destructive flows (delete, overwrite) are explicit and gated. No media file may be deleted or overwritten without an explicit safety gate.
- Source: `docs/codex/REPO_OVERVIEW.md` ("Originals remain untouched by default; destructive flows are explicit and gated.")
- Source: `AGENTS.md` ("Originals untouched.")

**Dry-run is the default mode.**
`DRY_RUN=1` unless explicitly overridden. Conversion must never write output without operator confirmation.
- Source: `.trae/rules/project_rules.md` ("Safety-first: dry-run default; explicit apply gates")

**Media transforms must be deterministic and reproducible.**
No implicit ffmpeg behavior. Codec, container, and stream mapping must be explicit.
- Source: `AGENTS.md` ("Media transforms must be deterministic and reproducible. Prefer explicit codec/container rules over implicit ffmpeg behavior.")
- Source: `docs/codex/REPO_OVERVIEW.md` ("Media transforms should be deterministic/reproducible. Explicit codec/container/stream mapping policy is preferred.")

---

## Secrets

**Never commit secrets, API keys, or credentials.**
No secrets in tracked files, logs, fixtures, examples, or environment templates.
- Source: `AGENTS.md` ("Never add or expose secrets in tracked files, logs, fixtures, or examples.")
- Source: `.trae/rules/project_rules.md` ("Never commit secrets.")

---

## Bash compatibility

**Bash 3.2+ only. No Bash 4+ features.**
Target is macOS baseline (`/bin/bash`). No arrays beyond simple indexed use, no `declare -A`, no `[[ ]]` with Bash 4 extensions that are not safe on 3.2.
- Source: `.trae/rules/project_rules.md` ("Bash 3.2 compatibility (/bin/bash on macOS). No Bash 4+.")
- Source: `docs/codex/REPO_OVERVIEW.md` ("Target environment: macOS/Linux, Bash 3.2+")

---

## Scope discipline

**Keep diffs narrow and task-scoped.**
Do not perform unrelated refactors, formatting churn, or broad cleanup as part of milestone work.
- Source: `AGENTS.md` ("Keep diffs narrow and task-scoped. Do not perform unrelated refactors or formatting churn.")

**One milestone at a time.**
Execute one coherent milestone per session. Do not collapse multiple milestone contracts into one pass.
- Source: `docs/codex/RUNBOOK.md` ("Implement one milestone-sized change.")

---

## Milestone gate rules

**Milestone completion is determined by the PLAN contract plus DOC_SYNC_MATRIX blocking rules.**
- Source: `docs/codex/RUNBOOK.md`, `docs/codex/REPO_OVERVIEW.md`, `AGENTS.md`, `docs/codex/DOC_SYNC_MATRIX.md` (all repeat this rule verbatim)

**Non-blocking hygiene items must NOT block milestone advancement.**
Record as follow-ups in `docs/codex/STATUS.md` or checkpoint notes. Do not fail a gate on non-blocking items.
- Source: `docs/codex/DOC_SYNC_MATRIX.md` ("Non-blocking cells must be tracked as follow-ups and must not auto-fail the milestone gate.")

---

## Downstream exports

**`docs/project-files/*` is downstream/export-only.**
It exists to generate concise files for upload into this repository's ChatGPT Project. It is not a primary source of truth for workflow decisions.
- Source: `AGENTS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/DOC_SYNC_MATRIX.md` (all repeat this rule)

---

## Validation order

**Always run validation in this sequence:**
1. Narrow milestone-specific validation first
2. `bash scripts/check-fast.sh`
3. `bash scripts/check-changed.sh` (only if present and relevant)
4. `bash scripts/check-full.sh` (only if justified)

Heavier checks must not be run instead of lighter ones. Skipping lighter checks requires explicit justification.
- Source: `AGENTS.md`, `docs/codex/RUNBOOK.md`, `docs/codex/REPO_OVERVIEW.md`

---

## Session memory

**Do not treat agent session memory or conversation history as durable workflow truth.**
Always re-read from the repository. Session context may be stale or incomplete.
- Source: `docs/codex/usage-prompts/0000-README.md` ("Do not rely on agent session memory as a source of truth.")

---

## Anti-loop

**Do not use the full repo audit as a normal milestone gate.**
**Do not use blocker-closure as a broad repo re-review.**
**Do not use release-prep as a general cleanup prompt.**
- Source: `docs/codex/usage-prompts/0000-README.md` (Anti-loop rule section)

---

## ShellCheck

**ShellCheck is required for PRs touching shell scripts.**
Prefer `shellcheck-py` via pip. CI must not rely on Homebrew.
- Source: `.trae/rules/project_rules.md`
