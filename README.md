# Jellyfin Converter

![CI](https://github.com/mt/jellyfin-converter/actions/workflows/ci.yml/badge.svg)

`jellyfin-converter` is a **safety-first local conversion tool for a single operator**, centered on **deterministic stream-selection** and **explicit destructive-action gates**, with a **CLI as the canonical execution path** and a **thin local GUI for operator convenience**.

## Product focus (v1)

### What this tool does
- Converts local media into Jellyfin-friendly MKV outputs.
- Applies deterministic probe/selection/mapping rules (audio + subtitles).
- Verifies outputs before any destructive cleanup path is allowed.
- Tracks processed files for repeat-run safety.

### Who v1 is for
- Single technical operator (local maintainer workflow).

### Explicitly not v1
- Consumer-grade GUI product.
- Multi-user auth/roles.
- Cloud/hosted conversion.
- Web frontend.
- Media-library management beyond conversion.

## Canonical v1 workflow
1. Scan input.
2. Probe streams.
3. Apply deterministic selection/mapping.
4. Write MKV output.
5. Verify result.
6. Optionally run destructive cleanup after explicit confirmation.

## Mandatory safety invariants
- `DRY_RUN=1` by default.
- Delete is off by default.
- Explicit confirmation is required for destructive actions.
- Output verification is required before destructive cleanup.
- Guardrails prevent recursive output churn.
- Processed tracking is part of repeat-run safety.

## Documentation
- [Scope & Version Boundaries](docs/scope.md)
- [Architecture & Layer Boundaries](docs/architecture.md)
- [CLI Contract v1](docs/cli-contract-v1.md)
- [Compatibility Matrix](docs/compatibility-matrix.md)
- [User Guide](docs/user-guide.md)
- [Subtitle Policy & Configuration](docs/subtitles.md)
- [Release/Milestone Direction](docs/NEXT_STEPS.md)
- [Security Policy](SECURITY.md)

## Control-plane references (contributors)
- Plan/status/runbook: `docs/codex/PLAN.md`, `docs/codex/STATUS.md`, `docs/codex/RUNBOOK.md`
- Documentation sync rules: `docs/codex/DOC_SYNC_MATRIX.md`
- Codex prompt pack: `docs/codex/usage-prompts/`

## Supported platforms
- macOS and Linux (both release-blocking in CI)
- Bash 3.2+
- `ffmpeg`, `ffprobe`, `find`, `df` on `PATH`
- Optional: `gnu-parallel` for faster runs

## Install (GitHub release assets)
```bash
curl -fsSL https://raw.githubusercontent.com/mt/jellyfin-converter/main/install.sh | \
  bash -s -- --version v1.0.0
```

By default installer chooses `/usr/local` when writable, otherwise user-local paths.

Installed binary:
```bash
jellyfin-converter --version
jellyfin-converter --self-check
```

## Local repo usage
```bash
./run.sh --dry-run /path/to/videos
```

Real conversion (keep originals):
```bash
DRY_RUN=0 DELETE=0 ./run.sh /path/to/videos
```

Enable deletion only after validation confidence:
```bash
DRY_RUN=0 DELETE=1 DELETE_SIDECARS=1 ./run.sh /path/to/videos
```

## Release assets contract
- `release.tar.gz`
- `checksums.txt` (sha256)
- `install.sh`

## CI gates
- Bash syntax
- ShellCheck
- Bash 3.2 compatibility
- Full test suite on macOS + Linux
- Release dry-run packaging and installer validation
- Action pinning check and release-doc/version sync check

## Reporting bugs
Open an issue on GitHub with:
- OS version
- `jellyfin-converter --version` output
- command used and console logs (prefer `DRY_RUN=1`)
