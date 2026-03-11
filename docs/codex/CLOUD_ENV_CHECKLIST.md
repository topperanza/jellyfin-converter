# Codex Cloud Environment Checklist

Use this checklist to confirm non-repo Cloud environment parity before milestone work.
Do not store real secrets here; use variable names/placeholders only.

## Required runtime versions
- [ ] Bash available (`bash`) and compatible with repo scripts (Bash 3.2+ baseline).
- [ ] `git` available for changed-file checks and normal repo operations.
- [ ] `ffmpeg` and `ffprobe` available for conversion/self-check paths.
- [ ] Core POSIX tools available on `PATH` (`find`, `df`, `sed`, `awk`).

## Required package managers / toolchains
- [ ] At least one supported package manager exists if system deps must be installed:
  - [ ] `apt-get`, or
  - [ ] `dnf`, or
  - [ ] `yum`, or
  - [ ] `brew`
- [ ] Shell tooling required by validation scripts is available (`bash`, executable permissions support).

## Required environment variables
- [ ] `JELLYFIN_CONVERTER_ROOT` is exported (usually generated via `.codex/env.sh`).
- [ ] `CODEX_SKIP_SYSTEM_DEPS` is set intentionally (`1` only when skipping system dependency installs is acceptable).
- [ ] Optional runtime toggles (`DRY_RUN`, `DELETE`, `DELETE_SIDECARS`) are set intentionally when used for manual conversion checks.

## Required secrets
- [ ] No repository-specific runtime secret is required for local conversion/test execution.
- [ ] If Cloud flow includes remote git operations, provide auth via workspace secret store (for example `GITHUB_TOKEN`), never committed files.
- [ ] No secret values are written to docs, prompts, checkpoints, or logs.

## Internet access expectations
- [ ] Internet access is available if setup may install missing system deps (`ffmpeg`/`ffprobe`).
- [ ] Internet access is available if milestone tasks include remote git/GitHub operations.
- [ ] Core validation can still run without internet when required tools are already present.

## Setup script requirement
- [ ] Run `bash scripts/codex/setup.sh` at least once for fresh Cloud environments.
- [ ] Confirm `.codex/env.sh` and `.codex/checkpoints/` are created/ready.
- [ ] Confirm setup smoke validation passed (`bash scripts/check-fast.sh` or reduced parser-only fallback when media tools are unavailable).

## Maintenance script requirement
- [ ] Run `bash scripts/codex/maintenance.sh` for resumed/warm environments before milestone execution.
- [ ] Confirm maintenance sanity check passed (`bash scripts/check-fast.sh` or fallback syntax check path).

## Cache reset triggers
- [ ] Reset/recreate cached environment when base image/runtime changes (shell/toolchain drift).
- [ ] Reset/recreate cached environment when setup or validation scripts change materially.
- [ ] Reset/recreate cached environment when repeated unexplained validation failures suggest stale permissions, stale dependencies, or broken `PATH`.
- [ ] Re-run setup after cache reset and re-verify with `bash scripts/check-fast.sh`.

## Repo-specific cloud/local caveats
- [ ] Prefer Codex Cloud for planning, normal milestone implementation, gate checks, docs/control-plane updates, and repo-wide recovery audits.
- [ ] Prefer Codex Local app for environment-sensitive fixes, script/toolchain/platform-sensitive verification, final local verification, and commit/push.
- [ ] `docs/project-files/` remains downstream export only; docs/codex/* + code/tests/config remain source of truth for milestone decisions.
