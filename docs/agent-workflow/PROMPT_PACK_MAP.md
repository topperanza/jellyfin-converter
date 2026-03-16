# Prompt Pack Map

Maps the Codex-facing prompt pack (`docs/codex/usage-prompts/`) to its
intent, the canonical shared-layer file that expresses that intent, and
any adapter-specific notes.

The prompt pack location is canonical and must not be moved.
See `docs/codex/WORKFLOW_VERSION.md` for the versioned `PROMPTS_DIR` path.

## Current prompt pack (v1.3.0)

| Prompt file | Intent | Shared-layer reference | Notes |
|---|---|---|---|
| `0000-README.md` | Index and usage order | `WORKFLOW_ORDER.md` | Authoritative usage order; all agents should read this |
| `000-repo-audit.md` | Recovery-only full repo audit | `WORKFLOW_ORDER.md` § Recovery flow | Use only when control plane is untrustworthy |
| `00-repo-starter.md` | Day-0 initialization | `WORKFLOW_ORDER.md` § Day-0 flow | Use only for new repos |
| `01-next-milestone-planner.md` | Plan the next milestone | `WORKFLOW_ORDER.md` § Standard flow | Cloud-only; read canonical docs first |
| `02-milestone-implementation.md` | Implement one milestone | `WORKFLOW_ORDER.md` § Standard flow | Cloud-only; keep diff narrow |
| `03-milestone-gate.md` | Gate the completed milestone | `WORKFLOW_ORDER.md` § Standard flow | Contract-scoped gate only, not full audit |
| `04-blocker-patch.md` | Fix a specific blocker | `WORKFLOW_ORDER.md` § Blocked flow | Smallest corrective patch only |
| `05-blocker-closure-check.md` | Confirm blocker is closed | `WORKFLOW_ORDER.md` § Blocked flow | Narrow check — not a re-gate |
| `06A-local-handoff+verification.md` | Bring cloud work local + verify | `WORKFLOW_ORDER.md` § Local verification | Use when fetching from remote branch |
| `06B-local-verification.md` | Verify work already local | `WORKFLOW_ORDER.md` § Local verification | Use when work is already on local branch |
| `07A-commit-push.md` | Commit and push | `WORKFLOW_ORDER.md` § Commit/merge | Local-only; no force-push |
| `07B-squash-merge.md` | Squash-merge to main | `WORKFLOW_ORDER.md` § Commit/merge | Local-only; only when not already on main |
| `08-release-prep.md` | Review before release | `WORKFLOW_ORDER.md` § Release flow | Run before tag/release |
| `09-tag&release.md` | Tag and create release | `WORKFLOW_ORDER.md` § Release flow | Final step after prep and commit |

## Old → new filename migration

These filenames are obsolete. The conformance script
(`scripts/codex/check-workflow-conformance.sh`) actively rejects references to them
in active control-plane docs.

| Old filename | Replaced by |
|---|---|
| `0000-README-usage-order.md` | `0000-README.md` |
| `000-full-repo-audit-recovery-only.md` | `000-repo-audit.md` |
| `06-final-local-verification.md` | `06A-local-handoff+verification.md` + `06B-local-verification.md` |
| `07-commit-and-push-after-pass.md` | `07A-commit-push.md` |
| `09-tag-and-release.md` | `09-tag&release.md` |

## Adapter consumption

| Adapter | Prompts it primarily uses |
|---|---|
| Codex (cloud) | 00 → 01 → 02 → 03 → [04/05] → 08 |
| Claude Code (local) | 06A / 06B → 07A → [07B] → 09 |
| Aider (local) | 06B → 07A (Aider handles targeted implementation; commit/push is still explicit) |
