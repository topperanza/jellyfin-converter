# Changelog

## Unreleased
- Documentation realignment: product vision/scope now explicitly positions jellyfin-converter as a safety-first local conversion tool for a single operator.
- Added explicit v1/v1.1/v2 boundaries and non-goals (no web frontend, multi-user auth, cloud/hosted execution, or broader media-library management in v1).
- Clarified architecture framing into core conversion, safety/state, CLI canonical surface, thin local GUI, packaging/distribution, validation, and control-plane layers.
- Refocused roadmap/milestone narrative toward a runtime-confidence next step for high-risk stream-selection/subtitle/ffmpeg mapping behavior.

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
