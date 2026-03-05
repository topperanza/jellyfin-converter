# GA Release Checklist

## Required gates
- CI is green on `ubuntu-latest` and `macos-latest`.
- Bash syntax, ShellCheck, Bash 3.2 compatibility checks are green.
- Release dry-run workflow passes: packaging, checksums, installer validation.
- `scripts/validate_release_docs.sh` passes for current `VERSION`.
- `scripts/check_action_pinning.sh` passes.

## Pre-GA validation
- Installer tested from scratch on macOS and Linux.
- Known issues and mitigations updated.
- Release notes and migration notes for `vX.Y.Z` finalized.

## GA execution
- Create tag `vX.Y.Z`.
- Publish release assets: `release.tar.gz`, `checksums.txt`, `install.sh`.
- Confirm install quick-start in `README.md`.

## Post-GA stabilization (2-4 weeks)
- Patch-only changes unless critical.
- Track top failure classes and publish patch releases as needed.
