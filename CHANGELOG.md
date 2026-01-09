# Changelog

## v1.1.0
- Default scan now excludes output directories and hidden folders.
- Fix: normalize missing language tags to 'und' (undetermined).
- CI: Switched to `shellcheck-py` for reproducible linting.

## v1.0.0
- Deterministic subtitle selection
- Strict subtitle sidecar anchoring (safety fix)
- Forced/default propagation
- CI with shellcheck-py (no Homebrew)
- Bash 3.2 compatibility guaranteed

## 0.2.0-alpha
- Added `run.sh` entrypoint with dry-run default.
- Harder dependency checks and clearer usage/help output.
- Updated docs, versioning, and smoke tests for release readiness.
