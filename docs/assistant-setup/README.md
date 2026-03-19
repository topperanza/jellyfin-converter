# Assistant Setup

This directory contains share-safe configuration examples and policy documentation for the AI coding assistants used in this project (Claude Code, Codex, Aider).

## Files in This Directory

| File | Purpose |
|---|---|
| `ASSISTANT_SETTINGS_POLICY.md` | Policy governing what is committed vs. kept local |
| `README.md` | This file |
| `claude.settings.local.example.json` | Example `.claude/settings.local.json` — copy and adapt locally |
| `codex.user.example.toml` | Example `~/.codex/config.toml` — copy and adapt locally |
| `aider.env.example` | Example Aider env file — copy and adapt locally |

All files with `.example.` in the name are **examples only**. They contain no real secrets and must not be used directly. Copy them to the correct local path and populate with your own values.

## Mirroring This Setup on Another Machine

### 1. Claude Code

The repo-scoped settings are in `.claude/settings.json` and arrive with the clone.

For local overrides (optional):

```sh
cp docs/assistant-setup/claude.settings.local.example.json .claude/settings.local.json
# Edit .claude/settings.local.json — do not commit it
```

### 2. Codex

The repo-scoped config is in `.codex/config.toml` and arrives with the clone.

For user-level config (model selection, API key, personal preferences):

```sh
cp docs/assistant-setup/codex.user.example.toml ~/.codex/config.toml
# Edit ~/.codex/config.toml — do not commit it
```

### 3. Aider

```sh
cp docs/assistant-setup/aider.env.example .env.aider.local
# Edit .env.aider.local and populate your keys
# Source it before running aider: source .env.aider.local
# Do not commit the populated file
```

## Which Files to Copy vs. Use Directly

| Source (this dir) | Copy to | Commit the copy? |
|---|---|---|
| `claude.settings.local.example.json` | `.claude/settings.local.json` | No — local only |
| `codex.user.example.toml` | `~/.codex/config.toml` | No — home dir |
| `aider.env.example` | `.env.aider.local` (or similar) | No — contains secrets |

The example files themselves stay in Git. Your populated local copies do not.

## Verification Checklist

- [ ] `.claude/settings.local.json` is listed in `.gitignore` (or `.claude/` is ignored)
- [ ] `~/.codex/auth.json` is never staged
- [ ] No API keys appear in `git diff --cached`
- [ ] All example files contain only placeholder values
- [ ] `AGENTS.md` and `docs/agent-workflow/*` are the canonical shared instruction surface

See `ASSISTANT_SETTINGS_POLICY.md` for the full policy and verification commands.
