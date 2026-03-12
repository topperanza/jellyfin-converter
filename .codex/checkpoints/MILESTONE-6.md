# Milestone 6: control-plane follow-up hardening cleanup
- Date: 2026-03-12
- Goal: close non-blocking hardening follow-ups by tightening prompt-path discoverability and reducing audit confusion around legacy prompt naming.
- Completion criteria: README includes canonical prompt-pack path, downstream validation summary aligns to milestone-first ordering, conformance script checks legacy prompt-path references in active docs, and remote release/tag evidence is attempted and recorded.

## Files changed
- `docs/codex/PLAN.md`
- `README.md`
- `docs/project-files/validation-summary.md`
- `.codex/checkpoints/README.md`
- `scripts/codex/check-workflow-conformance.sh`
- `docs/codex/WORKFLOW_VERSION.md`
- `docs/codex/STATUS.md`
- `.codex/checkpoints/MILESTONE-6.md`

## Commands run
- `bash scripts/codex/check-workflow-conformance.sh`
- `bash scripts/check-fast.sh`
- `bash scripts/check-changed.sh HEAD~1`
- `git ls-remote --tags origin`
- `gh release list`

## Results
- Pass: conformance checks passed after adding legacy prompt-path reference guards for active docs.
- Pass: fast validation (`bash scripts/check-fast.sh`).
- Pass: changed-file validation (`bash scripts/check-changed.sh HEAD~1`).
- Not evidenced: remote tags (`git ls-remote --tags origin`) due missing `origin` remote in this workspace.
- Not evidenced: GitHub release list (`gh release list`) due missing `gh` CLI.

## Risks / next step
- Risk: remote release/tag state is still not evidenced in this environment; verify in a repo clone with configured `origin` and GitHub CLI/auth.
- Next step: proceed to next numbered milestone in `docs/codex/PLAN.md`.
