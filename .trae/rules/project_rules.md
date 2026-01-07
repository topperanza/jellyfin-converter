# Trae Project Rules — jellyfin-converter

- Bash 3.2 compatibility (/bin/bash on macOS). No Bash 4+.
- Safety-first: dry-run default; explicit apply gates; deterministic planning/output.
- Minimal deps; CI must NOT rely on Homebrew.
- ShellCheck: prefer shellcheck-py via pip; support mirrors via PIP_INDEX_URL / PIP_EXTRA_INDEX_URL and proxies via HTTP_PROXY/HTTPS_PROXY.
- Never commit secrets.
- Evidence-first edits (rg/grep, cite file:line). Smallest safe change + tests/fixtures.
- One PR per item; conventional commits.
- Verification per PR: bash -n, shellcheck, tests.
- PR output must include: branch, changed files, commands run + results, PR description (repro/fix/validate/risk).

