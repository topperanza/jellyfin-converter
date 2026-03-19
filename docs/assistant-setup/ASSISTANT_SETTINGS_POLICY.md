# Assistant Settings Policy

## Purpose

This policy governs which assistant configuration files are committed to the repository and which remain local-only. It applies to all AI coding assistants used in this project (Claude Code, Codex, Aider, and similar tools).

## Tracked in Git (share-safe)

These files are committed and safe to share:

| File | Assistant | What it configures |
|---|---|---|
| `.codex/config.toml` | Codex | Repo-scoped workflow behavior, guards, doc pointers |
| `.claude/settings.json` | Claude Code | Repo-scoped permissions and defaults |
| `AGENTS.md` | All | Shared agent instructions |
| `docs/agent-workflow/*` | All | Canonical workflow documentation |
| `docs/assistant-setup/*.example.*` | All | Sanitized example configs |

## Local-Only, Never Committed

These files must never appear in a commit:

| File | Reason |
|---|---|
| `.claude/settings.local.json` | May contain machine-specific overrides |
| `~/.codex/auth.json` | Auth tokens — never committed |
| `~/.codex/config.toml` | User-level model/key preferences |
| `~/.claude/settings.json` | User-level Claude Code preferences |
| `.env`, `*.env.local` | May contain real API keys |
| Any file containing a real API key or token | Obvious |

## Rules

1. **Commit share-safe repo config only.** If it contains a key, token, path, or username, it does not go in Git.
2. **Never commit `.claude/settings.local.json`** — this file is always local-only regardless of content.
3. **Never commit `~/.codex/auth.json`** — Codex authentication state is never tracked.
4. **Never commit active user config from home directories** (`~/.codex/config.toml`, `~/.claude/settings.json`, etc.).
5. **Examples are allowed only when sanitized** — example files must use placeholder values (`YOUR_API_KEY`, `your-model-name`) and be clearly named with `.example.` in the filename.
6. **Secrets come from local env or a password manager, never from Git.** Copy from the `.example` files and populate locally.

## Replication Model

To mirror this setup on another machine:

1. Clone the repo — all share-safe config arrives automatically.
2. Copy example files to their local destinations (see `docs/assistant-setup/README.md`).
3. Populate secrets from your password manager or environment.
4. Do not commit the populated files.

## Verification Steps

Before committing assistant config changes:

```sh
# Confirm .claude/settings.local.json is gitignored
git check-ignore -v .claude/settings.local.json

# Confirm no auth or secret files are staged
git diff --cached --name-only | grep -E '(auth|secret|\.local\.|\.env)'

# Confirm no API keys appear in staged content
git diff --cached | grep -iE '(api[_-]?key|token|secret)\s*=\s*[^<]'
```

All three checks should produce no output before you push.
