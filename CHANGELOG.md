# Changelog

## v1.0.0
- Default scan now excludes output directories and hidden folders.
- Fix: normalize missing language tags to 'und' (undetermined).
- CI: Switched to `shellcheck-py` for reproducible linting.
- Added stable installer entrypoint (`install.sh`) with mandatory checksum verification.
- Added release packaging workflow (`release.tar.gz`, `checksums.txt`) and installer validation gates.
- Added CLI `--self-check`, v1 contract docs, compatibility matrix, and operational runbooks.

## 0.2.0-alpha
- Added `run.sh` entrypoint with dry-run default.
- Harder dependency checks and clearer usage/help output.
- Updated docs, versioning, and smoke tests for release readiness.
